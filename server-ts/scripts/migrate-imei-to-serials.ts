import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function migrate() {
  try {
    console.log("Checking for items with legacy IMEI...");

    // Use raw SQL to safely access legacy column if present
    const rows: Array<{
      id: number;
      imei: string | null;
      batch_id: number | null;
    }> = (await prisma.$queryRawUnsafe(
      `SELECT id, imei, batch_id FROM items WHERE imei IS NOT NULL AND imei != ''`
    )) as any;

    if (!rows || rows.length === 0) {
      console.log("No legacy IMEIs detected. Nothing to migrate.");
      return;
    }

    console.log("Found", rows.length, "items with IMEI. Migrating...");

    for (const r of rows) {
      const { id, imei, batch_id } = r;
      if (!imei) continue;

      // Insert into serials table - assume prisma.serial exists after generate
      try {
        // eslint-disable-next-line @typescript-eslint/ban-ts-comment
        // @ts-ignore
        await prisma.serial.create({
          data: {
            imei,
            itemId: id,
            batchId: batch_id ?? undefined,
          },
        });
        console.log(`Migrated IMEI '${imei}' for item ${id}`);
      } catch (err) {
        console.error(`Failed to create serial for item ${id}:`, err);
      }
    }

    console.log("Migration complete.");
  } catch (e) {
    console.error("Migration failed:", e);
  } finally {
    await prisma.$disconnect();
  }
}

migrate()
  .catch((e) => {
    console.error("Unhandled error migrating IMEIs:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
