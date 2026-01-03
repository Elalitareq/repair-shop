import { PrismaClient } from "@prisma/client";
import * as fs from "fs";
import * as path from "path";

const prisma = new PrismaClient();

async function main() {
  console.log("Starting inventory import...");

  const dataPath = path.join(__dirname, "../../data/inventory_import.json");
  if (!fs.existsSync(dataPath)) {
    console.error(`File not found: ${dataPath}`);
    return;
  }

  const rawData = fs.readFileSync(dataPath, "utf-8");
  const items = JSON.parse(rawData);

  console.log(`Found ${items.length} items to import.`);

  // --- 1. Cache Reference Data ---
  // We will cache IDs to avoid repeated DB lookups
  const categories: Record<string, number> = {};
  const conditions: Record<string, number> = {};
  const qualities: Record<string, number> = {};
  const suppliers: Record<string, number> = {};

  async function getCategoryId(name: string): Promise<number> {
    if (categories[name]) return categories[name];
    let cat = await prisma.category.findUnique({ where: { name } });
    if (!cat) {
      console.log(`Creating Category: ${name}`);
      cat = await prisma.category.create({ data: { name } });
    }
    categories[name] = cat.id;
    return cat.id;
  }

  async function getConditionId(name: string): Promise<number> {
    if (conditions[name]) return conditions[name];
    let cond = await prisma.condition.findUnique({ where: { name } });
    if (!cond) {
      console.log(`Creating Condition: ${name}`);
      cond = await prisma.condition.create({ data: { name } });
    }
    conditions[name] = cond.id;
    return cond.id;
  }

  async function getQualityId(name: string): Promise<number> {
    if (qualities[name]) return qualities[name];
    let qual = await prisma.quality.findUnique({ where: { name } });
    if (!qual) {
      console.log(`Creating Quality: ${name}`);
      qual = await prisma.quality.create({ data: { name } });
    }
    qualities[name] = qual.id;
    return qual.id;
  }

  async function getSupplierId(name: string, phone: string): Promise<number> {
    const key = name || "Unknown";
    if (suppliers[key]) return suppliers[key];

    // Try to find by phone if valid
    let supplier = null;
    if (phone && phone.length > 5) {
      supplier = await prisma.customer.findUnique({ where: { phone } });
    }

    // Or find by name if phone didn't work (or wasn't provided)
    if (!supplier && name) {
      // Check if name is unique enough? Name is not unique in Schema, only phone is.
      // We'll trust findFirst for now if phone logic failed or missing
      supplier = await prisma.customer.findFirst({
        where: { name, type: "supplier" },
      });
    }

    if (!supplier) {
      // Default Fallback creation
      const safeName = name || "Unknown Supplier";
      // Generate a fake unique phone if missing to satisfy unique constraint
      const safePhone =
        phone && phone.length > 5
          ? phone
          : `000000${Math.floor(Math.random() * 100000)}`;

      console.log(`Creating Supplier: ${safeName} (${safePhone})`);
      try {
        supplier = await prisma.customer.create({
          data: {
            name: safeName,
            phone: safePhone,
            type: "supplier",
          },
        });
      } catch (e) {
        // Determine if failure was due to duplicate phone on 'Unknown'
        // If so, just grab the first one
        supplier = await prisma.customer.findFirst({
          where: { phone: safePhone },
        });
        if (!supplier) throw e;
      }
    }
    suppliers[key] = supplier.id;
    return supplier.id;
  }

  // --- 2. Process Items ---

  for (const itemData of items) {
    try {
      // IDs
      const catId = await getCategoryId(itemData.category);
      const condId = await getConditionId(itemData.condition);
      const qualId = await getQualityId(itemData.quality);
      const suppId = await getSupplierId(
        itemData.supplier.name,
        itemData.supplier.phone
      );

      // Upsert Item
      // Use Name + Category as quasi-unique check via findFirst if no barcode, but schema doesn't force unique name.
      // Barcode logic: we treat the FIRST imei or code as the "Barcode" for lookup.
      // Better to check if existing item by Name?

      // Let's create a new item if it doesn't exist.
      // We search by name AND category to avoid duplicates
      let item = await prisma.item.findFirst({
        where: {
          name: itemData.name,
          categoryId: catId,
        },
      });

      if (!item) {
        console.log(`Creating Item: ${itemData.name}`);
        item = await prisma.item.create({
          data: {
            name: itemData.name,
            brand: itemData.brand,
            model: itemData.model,
            categoryId: catId,
            conditionId: condId,
            qualityId: qualId,
            itemType: itemData.itemType,
            sellingPrice: itemData.sellingPrice,
            stockQuantity: 0, // Will be updated via batch/stock logic in real app, but here we set initial
            minStockLevel: 1,
            description: itemData.description,
          },
        });
      } else {
        console.log(`Updating Item: ${itemData.name}`);
        await prisma.item.update({
          where: { id: item.id },
          data: {
            brand: itemData.brand,
            model: itemData.model,
            sellingPrice: itemData.sellingPrice,
            description: itemData.description,
          },
        });
      }

      // --- 3. Create Batch ---
      // Always create a NEW batch for this import? Or try to dedupe?
      // To prevent double import issues if script re-runs, let's look for a batch
      // with same supplier + approximate date (today) + itemId ?
      // Or simpler: Just create it. The user said to import.

      // NOTE: The `item.stockQuantity` field is basically a cache.
      // We should increment it.

      const batch = await prisma.batch.create({
        data: {
          batchNumber: `IMP-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
          supplierId: suppId,
          itemId: item.id,
          purchaseDate: new Date(),
          totalQuantity: itemData.batch.quantity,
          soldQuantity: 0,
          unitCost: itemData.batch.unitCost,
          totalCost: itemData.batch.unitCost * itemData.batch.quantity,
          notes: "Initial Import",
        },
      });

      // Update Item Stock
      await prisma.item.update({
        where: { id: item.id },
        data: { stockQuantity: { increment: itemData.batch.quantity } },
      });

      // --- 4. Create Serials ---
      if (itemData.serials && itemData.serials.length > 0) {
        for (const imei of itemData.serials) {
          // Check if exists to avoid unique constraint error
          const exists = await prisma.serial.findUnique({ where: { imei } });
          if (!exists) {
            await prisma.serial.create({
              data: {
                imei: imei,
                itemId: item.id,
                batchId: batch.id,
                status: "available",
              },
            });
          } else {
            console.warn(`Skipping duplicate IMEI: ${imei}`);
          }
        }
      } else if (itemData.barcode) {
        // If "Part" has a code (barcode), add it to Barcode table?
        // Schema has `Barcode` model.
        if (itemData.itemType === "other") {
          // Check existence
          const existingBarcode = await prisma.barcode.findUnique({
            where: { barcode: itemData.barcode },
          });
          if (!existingBarcode) {
            await prisma.barcode.create({
              data: {
                barcode: itemData.barcode,
                itemId: item.id,
              },
            });
          }
        }
      }
    } catch (error) {
      console.error(`Error processing item ${itemData.name}:`, error);
    }
  }

  console.log("Import completed.");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
