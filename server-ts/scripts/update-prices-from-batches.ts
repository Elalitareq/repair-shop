import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function updatePricesFromBatches() {
  try {
    console.log("Starting price update from batches...");

    // Get all items with their batches
    const items = await prisma.item.findMany({
      include: {
        batches: {
          orderBy: {
            purchaseDate: "desc", // Get most recent batch first
          },
          take: 1, // Only need the most recent batch
        },
      },
    });

    console.log(`Found ${items.length} items in total.`);

    let updatedCount = 0;
    let skippedCount = 0;

    for (const item of items) {
      // Skip if item has no batches
      if (!item.batches || item.batches.length === 0) {
        console.log(
          `Skipping item ${item.id} (${item.name}): No batches found`
        );
        skippedCount++;
        continue;
      }

      const latestBatch = item.batches[0];
      const newPrice = latestBatch.unitCost;

      // Update the item's selling price to match the batch unit cost
      await prisma.item.update({
        where: { id: item.id },
        data: { sellingPrice: newPrice },
      });

      console.log(
        `Updated item ${item.id} (${item.name}): ${item.sellingPrice} → ${newPrice}`
      );
      updatedCount++;
    }

    console.log("\n=== Update Summary ===");
    console.log(`Total items: ${items.length}`);
    console.log(`Updated: ${updatedCount}`);
    console.log(`Skipped (no batches): ${skippedCount}`);
    console.log("Price update complete.");
  } catch (e) {
    console.error("Price update failed:", e);
    throw e;
  } finally {
    await prisma.$disconnect();
  }
}

updatePricesFromBatches()
  .catch((e) => {
    console.error("Unhandled error updating prices:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
