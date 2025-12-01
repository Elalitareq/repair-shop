import { Response } from "express";
import { AppError } from "../middleware/errorHandler";
import { AuthRequest } from "../middleware/auth";
import { prisma } from "../utils/prisma";
import type { Item } from "@prisma/client";
import fs from "fs";

// Transform Prisma item to camelCase for mobile client
function transformItemToCamelCase(item: any) {
  return {
    ...item,
    categoryId: item.categoryId,
    conditionId: item.conditionId,
    qualityId: item.qualityId,
    itemType: item.itemType,
    stockQuantity: item.stockQuantity,
    minStockLevel: item.minStockLevel,
    sellingPrice: item.sellingPrice,
    createdAt: item.createdAt,
    updatedAt: item.updatedAt,
    // Include barcodes if available
    barcodes: item.barcodes?.map((b: any) => b.barcode),
    // Include last batch price if available
    lastBatchPrice: item.batches?.[0]?.unitCost || 0,
  };
}

export class ItemController {
  async getAll(req: AuthRequest, res: Response) {
    const {
      page = "1",
      limit = "50",
      categoryId,
      conditionId,
      qualityId,
      batchId,
      lowStock,
    } = req.query;
    const skip = (parseInt(page as string) - 1) * parseInt(limit as string);

    const where: any = {};
    if (categoryId) where.categoryId = parseInt(categoryId as string);
    if (conditionId) where.conditionId = parseInt(conditionId as string);
    if (qualityId) where.qualityId = parseInt(qualityId as string);
    if (batchId) where.batchId = parseInt(batchId as string);
    // lowStock is handled in application code because Prisma does not support direct
    // column-to-column comparison with query filters. We will fetch items and
    // filter by comparing `stockQuantity` to `minStockLevel` in-memory when requested.

    let items: any[] = [];
    let total = 0;

    if (lowStock === "true") {
      // fetch all (or you could use raw query for efficiency)
      const allItems = await prisma.item.findMany({
        where,
        include: {
          category: true,
          condition: true,
          quality: true,
          barcodes: true,
          batches: {
            orderBy: { purchaseDate: "desc" },
            take: 1,
          },
        },
        orderBy: { name: "asc" },
      });

      const filtered = allItems.filter(
        (it: Item) => it.stockQuantity <= it.minStockLevel
      );
      total = filtered.length;
      items = filtered.slice(skip, skip + parseInt(limit as string));
    } else {
      [items, total] = await Promise.all([
        prisma.item.findMany({
          where,
          skip,
          take: parseInt(limit as string),
          include: {
            category: true,
            condition: true,
            quality: true,
            barcodes: true,
            batches: {
              orderBy: { purchaseDate: "desc" },
              include: { supplier: true },
            },
          },
          orderBy: { name: "asc" },
        }),
        prisma.item.count({ where }),
      ]);
    }

    res.json({
      data: items.map(transformItemToCamelCase),
      pagination: {
        page: parseInt(page as string),
        limit: parseInt(limit as string),
        total,
        pages: Math.ceil(total / parseInt(limit as string)),
      },
    });
  }

  async search(req: AuthRequest, res: Response) {
    const { q } = req.query;

    if (!q) {
      throw new AppError(400, "Search query is required");
    }

    // 1. Search serials for IMEI matches
    // @ts-ignore
    const serialMatches = await prisma.serial.findMany({
      where: { imei: { contains: q as string } },
      select: { itemId: true },
    });
    const serialItemIds = serialMatches.map((s: any) => s.itemId);

    // 2. Search barcodes
    const barcodeMatches = await prisma.barcode.findMany({
      where: { barcode: { contains: q as string } },
      select: { itemId: true },
    });
    const barcodeItemIds = barcodeMatches.map((b: any) => b.itemId);

    // Combine IDs
    const itemIds = [...new Set([...serialItemIds, ...barcodeItemIds])];

    const items = await prisma.item.findMany({
      where: {
        OR: [
          { name: { contains: q as string } },
          { brand: { contains: q as string } },
          { model: { contains: q as string } },
          ...(itemIds.length > 0 ? [{ id: { in: itemIds } }] : []),
        ],
      },
      include: {
        category: true,
        condition: true,
        quality: true,
        barcodes: true,
        batches: {
          orderBy: { purchaseDate: "desc" },
          take: 1,
          include: { supplier: true },
        },
      },
      take: 50,
    });

    res.json({ data: items.map(transformItemToCamelCase) });
  }

  async getLowStock(_req: AuthRequest, res: Response) {
    const allItems = await prisma.item.findMany({
      include: {
        category: true,
        condition: true,
        quality: true,
        barcodes: true,
        batches: {
          orderBy: { purchaseDate: "desc" },
          take: 1,
        },
      },
      orderBy: { stockQuantity: "asc" },
    });

    const items = allItems.filter(
      (it: Item) => it.stockQuantity <= it.minStockLevel
    );

    res.json({ data: items.map(transformItemToCamelCase) });
  }

  async getById(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const item = await prisma.item.findUnique({
      where: { id: parseInt(id) },
      include: {
        category: true,
        condition: true,
        quality: true,
        serials: true,
        barcodes: true,
      },
    });

    if (!item) {
      throw new AppError(404, "Item not found");
    }

    res.json({ data: transformItemToCamelCase(item) });
  }

  async create(req: AuthRequest, res: Response) {
    const {
      name,
      categoryId,
      brand,
      model,
      description,
      conditionId,
      qualityId,
      itemType,
      stockQuantity,
      minStockLevel,
      sellingPrice,
      barcode, // Optional initial barcode
    } = req.body;

    if (
      !name ||
      !categoryId ||
      !conditionId ||
      !qualityId ||
      sellingPrice === undefined
    ) {
      console.log({
        name,
        categoryId,
        conditionId,
        qualityId,
        sellingPrice,
      });
      throw new AppError(400, "Required fields missing");
    }

    const item = await prisma.item.create({
      data: {
        name,
        categoryId,
        brand,
        model,
        description,
        conditionId,
        qualityId,
        itemType: itemType || "other",
        stockQuantity: stockQuantity || 0,
        minStockLevel: minStockLevel || 5,
        sellingPrice,
        barcodes: barcode
          ? {
              create: { barcode },
            }
          : undefined,
      },
      include: {
        category: true,
        condition: true,
        quality: true,
        barcodes: true,
      },
    });

    res.status(201).json({
      data: transformItemToCamelCase(item),
      message: "Item created successfully",
    });
  }

  async update(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const data = req.body;

    const item = await prisma.item.findUnique({
      where: { id: parseInt(id) },
    });

    if (!item) {
      throw new AppError(404, "Item not found");
    }

    // Handle barcode updates if passed (simple add, not replace for now)
    // For full management, use barcode controller
    const { barcode, ...updateData } = data;

    if (barcode) {
      // Add new barcode if not exists
      const exists = await prisma.barcode.findUnique({ where: { barcode } });
      if (!exists) {
        await prisma.barcode.create({
          data: { barcode, itemId: parseInt(id) },
        });
      }
    }

    const updated = await prisma.item.update({
      where: { id: parseInt(id) },
      data: updateData,
      include: {
        category: true,
        condition: true,
        quality: true,
        barcodes: true,
      },
    });

    res.json({
      data: transformItemToCamelCase(updated),
      message: "Item updated successfully",
    });
  }

  async delete(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const item = await prisma.item.findUnique({
      where: { id: parseInt(id) },
      include: {
        _count: {
          select: { saleItems: true, stockUsages: true },
        },
      },
    });

    if (!item) {
      throw new AppError(404, "Item not found");
    }

    if (item._count.saleItems > 0 || item._count.stockUsages > 0) {
      throw new AppError(
        400,
        "Cannot delete item with associated transactions"
      );
    }

    await prisma.item.delete({
      where: { id: parseInt(id) },
    });

    res.json({ message: "Item deleted successfully" });
  }

  async adjustStock(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { quantity, reason } = req.body;

    if (quantity === undefined) {
      throw new AppError(400, "Quantity is required");
    }

    const item = await prisma.item.findUnique({
      where: { id: parseInt(id) },
    });

    if (!item) {
      throw new AppError(404, "Item not found");
    }

    const newQuantity = item.stockQuantity + quantity;

    if (newQuantity < 0) {
      throw new AppError(400, "Insufficient stock");
    }

    const updated = await prisma.item.update({
      where: { id: parseInt(id) },
      data: {
        stockQuantity: newQuantity,
      },
      include: {
        category: true,
        condition: true,
        quality: true,
        barcodes: true,
      },
    });

    // Log stock usage if needed
    if (reason) {
      await prisma.stockUsage.create({
        data: {
          itemId: parseInt(id),
          quantity,
          unitCost: 0,
          reason,
        },
      });
    }

    res.json({
      data: transformItemToCamelCase(updated),
      message: "Stock adjusted successfully",
    });
  }

  async importInventory(req: AuthRequest, res: Response) {
    if (!req.file) {
      throw new AppError(400, "No file uploaded");
    }

    try {
      const fileContent = fs.readFileSync(req.file.path, "utf-8");
      const lines = fileContent.split("\n");
      // Skip header if present (Code,Description...)
      const startIndex = lines[0].toLowerCase().startsWith("code") ? 1 : 0;

      let importedCount = 0;
      let updatedCount = 0;

      // Get default references
      const category = await prisma.category.findFirst();
      const condition = await prisma.condition.findFirst();
      const quality = await prisma.quality.findFirst();

      const defaultCategoryId = category?.id || 1;
      const defaultConditionId = condition?.id || 1;
      const defaultQualityId = quality?.id || 1;

      for (let i = startIndex; i < lines.length; i++) {
        const line = lines[i].trim();
        if (!line) continue;
        // CSV Format: Code,Description,Quantity,Amount,Category,Brand,Model,SupplierName,SupplierPhone,SupplierType
        const parts = line.split(",");
        if (parts.length < 4) continue;

        const code = parts[0].trim();
        const description = parts[1].trim();
        const quantityStr = parts[2].trim();
        const amountStr = parts[3].trim();
        const category = parts[4]?.trim() || "";
        const brand = parts[5]?.trim() || "";
        const model = parts[6]?.trim() || "";
        const supplierName = parts[7]?.trim() || "MobileZone"; // Default to MobileZone if not provided
        const supplierPhone = parts[8]?.trim() || "70300065"; // Default phone if not provided
        const supplierType = parts[9]?.trim() || "dealer"; // Default to dealer if not provided

        console.log(`CSV Row ${i}: code="${code}", supplierName="${supplierName}", supplierPhone="${supplierPhone}", supplierType="${supplierType}"`);

        const quantity = parseFloat(quantityStr);
        const unitCost = parseFloat(amountStr); // Unit Cost from CSV

        if (!code || !description) continue;

        // Find or create supplier from CSV with name, phone, and type
        console.log(`Looking for supplier: name="${supplierName}", type="${supplierType}"`);
        let supplier = await prisma.customer.findFirst({
          where: { 
            type: supplierType,
            name: supplierName
          },
        });
        
        if (!supplier) {
          console.log(`Supplier not found, creating new supplier: name="${supplierName}", phone="${supplierPhone}", type="${supplierType}"`);
          // Create supplier if not found with CSV phone number and type
          supplier = await prisma.customer.create({
            data: {
              name: supplierName,
              type: supplierType, // Use type from CSV
              phone: supplierPhone, // Use phone from CSV
              email: `${supplierName.toLowerCase().replace(/\s+/g, '')}@example.com`,
              address: "Default Address",
            },
          });
          console.log(`Created supplier with ID: ${supplier.id}`);
        } else {
          console.log(`Found existing supplier: ID=${supplier.id}, name="${supplier.name}", type="${supplier.type}"`);
        }

        // Find or create category if provided
        let categoryId = defaultCategoryId;
        if (category) {
          // Try exact match first
          const existingCategory = await prisma.category.findFirst({
            where: { 
              name: {
                equals: category,
              }
            },
          });
          
          if (existingCategory) {
            categoryId = existingCategory.id;
          } else {
            // Try case-insensitive match
            const caseInsensitiveCategory = await prisma.category.findFirst({
              where: { 
                name: {
                  contains: category.toLowerCase()
                }
              },
            });
            
            if (caseInsensitiveCategory) {
              categoryId = caseInsensitiveCategory.id;
            } else {
              // Create new category
              const newCategory = await prisma.category.create({
                data: {
                  name: category,
                  parentId: null, // Top-level category
                },
              });
              categoryId = newCategory.id;
            }
          }
        }

        // 1. Check Barcode
        const existingBarcode = await prisma.barcode.findUnique({
          where: { barcode: code },
        });

        let itemId: number;

        if (existingBarcode) {
          itemId = existingBarcode.itemId;
          // Update Stock and create batch with unit cost and CSV supplier
          await prisma.batch.create({
            data: {
              batchNumber: `IMP-${Date.now()}-${i}`,
              supplierId: supplier.id, // Use supplier from CSV
              purchaseDate: new Date(),
              totalQuantity: quantity,
              unitCost: unitCost, // Use unit cost from CSV
              totalCost: unitCost * quantity, // Calculate total cost
              itemId: itemId,
              notes: "Imported via CSV",
            },
          });

          await prisma.item.update({
            where: { id: itemId },
            data: {
              stockQuantity: { increment: quantity },
              ...(category && { categoryId }),
              ...(model && { model }),
              ...(brand && { brand }),
            },
          });
          updatedCount++;
        } else {
          // 2. Check Item Name (Description)
          const existingItem = await prisma.item.findFirst({
            where: { name: description },
          });

          if (existingItem) {
            itemId = existingItem.id;
            // Create Barcode
            await prisma.barcode.create({
              data: { barcode: code, itemId },
            });
            // Create Batch & Update Stock
            console.log(`Creating batch for existing item with supplier ID: ${supplier.id}`);
            await prisma.batch.create({
              data: {
                batchNumber: `IMP-${Date.now()}-${i}`,
                supplierId: supplier.id, // Use supplier from CSV
                purchaseDate: new Date(),
                totalQuantity: quantity,
                unitCost: unitCost, // Use unit cost from CSV
                totalCost: unitCost * quantity, // Calculate total cost
                itemId: itemId,
                notes: "Imported via CSV",
              },
            });

            await prisma.item.update({
              where: { id: itemId },
              data: {
                stockQuantity: { increment: quantity },
                ...(category && { categoryId }),
                ...(model && { model }),
                ...(brand && { brand }),
              },
            });
            updatedCount++;
          } else {
            // 3. Create New Item
           await prisma.item.create({
              data: {
                name: description,
                sellingPrice: unitCost * 1.2, // Default selling price as 20% markup on unit cost
                categoryId,
                conditionId: defaultConditionId,
                qualityId: defaultQualityId,
                stockQuantity: quantity,
                minStockLevel: 5,
                ...(model && { model }),
                ...(brand && { brand }),
                barcodes: {
                  create: { barcode: code },
                },
                batches: {
                  create: {
                    batchNumber: `IMP-${Date.now()}-${i}`,
                    supplierId: supplier.id, // Use supplier from CSV
                    purchaseDate: new Date(),
                    totalQuantity: quantity,
                    unitCost: unitCost, // Use unit cost from CSV
                    totalCost: unitCost * quantity, // Calculate total cost
                    notes: "Imported via CSV",
                  },
                },
              },
            });
            importedCount++;
          }
        }
      }

      // Cleanup file
      fs.unlinkSync(req.file.path);

      res.json({
        message: `Imported ${importedCount} new items, updated ${updatedCount} existing items.`,
      });
    } catch (error) {
      // Ensure file is deleted on error
      if (req.file) fs.unlinkSync(req.file.path);
      throw error;
    }
  }
}
