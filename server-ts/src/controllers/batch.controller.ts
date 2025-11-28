import { Response } from "express";
import { AppError } from "../middleware/errorHandler";
import { AuthRequest } from "../middleware/auth";
import { prisma } from "../utils/prisma";

export class BatchController {
  async getAll(req: AuthRequest, res: Response) {
    const { page = "1", limit = "50" } = req.query;
    const skip = (parseInt(page as string) - 1) * parseInt(limit as string);

    const [batches, total] = await Promise.all([
      // @ts-ignore - prisma client will include batch model after generate
      prisma.batch.findMany({
        skip,
        take: parseInt(limit as string),
        include: { supplier: true, serials: true },
        orderBy: { purchaseDate: "desc" },
      }),
      // @ts-ignore
      prisma.batch.count(),
    ]);

    const mapped = batches.map((b: any) => ({
      batch: {
        id: b.id,
        batchNumber: b.batchNumber,
        supplierId: b.supplierId,
        purchaseDate: b.purchaseDate.toISOString(),
        totalQuantity: b.totalQuantity,
        soldQuantity: b.soldQuantity,
        unitCost: b.unitCost,
        totalCost: b.totalCost,
        notes: b.notes,
        createdAt: b.createdAt.toISOString(),
        updatedAt: b.updatedAt.toISOString(),
      },
      remainingStock: Math.max(
        0,
        (b.totalQuantity || 0) - (b.soldQuantity || 0)
      ),
      stockPercentage:
        b.totalQuantity && b.totalQuantity > 0
          ? ((b.totalQuantity - (b.soldQuantity || 0)) / b.totalQuantity) * 100
          : 0,
      isLowStock:
        b.totalQuantity && b.totalQuantity > 0
          ? ((b.totalQuantity - (b.soldQuantity || 0)) / b.totalQuantity) *
              100 <
            20
          : false,
      isOutOfStock: (b.totalQuantity || 0) - (b.soldQuantity || 0) <= 0,
    }));

    res.json({
      data: mapped,
      pagination: {
        page: parseInt(page as string),
        limit: parseInt(limit as string),
        total,
        pages: Math.ceil(total / parseInt(limit as string)),
      },
    });
  }

  async getById(req: AuthRequest, res: Response) {
    const { id } = req.params;
    // @ts-ignore
    const batch = await prisma.batch.findUnique({
      where: { id: parseInt(id) },
      include: { supplier: true, serials: true },
    });
    if (!batch) throw new AppError(404, "Batch not found");

    const response = {
      batch: {
        id: batch.id,
        batchNumber: batch.batchNumber,
        supplierId: batch.supplierId,
        purchaseDate: batch.purchaseDate.toISOString(),
        totalQuantity: batch.totalQuantity,
        soldQuantity: batch.soldQuantity,
        unitCost: batch.unitCost,
        totalCost: batch.totalCost,
        notes: batch.notes,
        createdAt: batch.createdAt.toISOString(),
        updatedAt: batch.updatedAt.toISOString(),
      },
      remainingStock: Math.max(
        0,
        (batch.totalQuantity || 0) - (batch.soldQuantity || 0)
      ),
      stockPercentage:
        batch.totalQuantity && batch.totalQuantity > 0
          ? ((batch.totalQuantity - (batch.soldQuantity || 0)) /
              batch.totalQuantity) *
            100
          : 0,
      isLowStock:
        batch.totalQuantity && batch.totalQuantity > 0
          ? ((batch.totalQuantity - (batch.soldQuantity || 0)) /
              batch.totalQuantity) *
              100 <
            20
          : false,
      isOutOfStock: (batch.totalQuantity || 0) - (batch.soldQuantity || 0) <= 0,
    };

    res.json({ data: response });
  }

  async create(req: AuthRequest, res: Response) {
    const {
      batchNumber,
      supplierId,
      purchaseDate,
      totalQuantity,
      totalCost,
      unitCost,
      notes,
      itemId, // Optional: if provided, update item stock
    } = req.body;
    if (
      totalQuantity === undefined ||
      totalCost === undefined ||
      unitCost === undefined ||
      !supplierId
    ) {
      console.log({
        batchNumber,
        supplierId,
        purchaseDate,
        totalQuantity,
        totalCost,
        unitCost,
      });
      throw new AppError(400, "Required fields missing");
    }

    // Generate a batch number when not provided
    let newBatchNumber = batchNumber;
    if (!newBatchNumber) {
      // Helper to create a simple unique batch number
      const generate = async () => {
        const date = new Date();
        const yyyymmdd = date.toISOString().slice(0, 10).replace(/-/g, "");
        const suffix = Math.floor(Math.random() * 90000) + 10000; // 5 digits
        return `BATCH-${yyyymmdd}-${suffix}`;
      };

      let attempts = 0;
      while (attempts < 10) {
        const candidate = await generate();
        // @ts-ignore
        const exists = await prisma.batch.findUnique({
          where: { batchNumber: candidate },
        });
        if (!exists) {
          newBatchNumber = candidate;
          break;
        }
        attempts++;
      }
      if (!newBatchNumber) {
        throw new AppError(500, "Failed to generate unique batch number");
      }
    }
    console.log({ newBatchNumber });
    // @ts-ignore
    const batch = await prisma.batch.create({
      data: {
        batchNumber: newBatchNumber,
        supplierId,
        purchaseDate: purchaseDate ? new Date(purchaseDate) : new Date(),
        totalQuantity,
        totalCost,
        unitCost,
        notes,
      },
      include: { supplier: true, serials: true },
    });

    // Update item stock if itemId is provided
    if (itemId) {
      await prisma.item.update({
        where: { id: parseInt(itemId) },
        data: {
          stockQuantity: {
            increment: totalQuantity,
          },
        },
      });
    }

    const response = {
      batch: {
        id: batch.id,
        batchNumber: batch.batchNumber,
        supplierId: batch.supplierId,
        purchaseDate: batch.purchaseDate.toISOString(),
        totalQuantity: batch.totalQuantity,
        soldQuantity: batch.soldQuantity,
        unitCost: batch.unitCost,
        totalCost: batch.totalCost,
        notes: batch.notes,
        createdAt: batch.createdAt.toISOString(),
        updatedAt: batch.updatedAt.toISOString(),
      },
      remainingStock: Math.max(
        0,
        (batch.totalQuantity || 0) - (batch.soldQuantity || 0)
      ),
      stockPercentage:
        batch.totalQuantity && batch.totalQuantity > 0
          ? ((batch.totalQuantity - (batch.soldQuantity || 0)) /
              batch.totalQuantity) *
            100
          : 0,
      isLowStock:
        batch.totalQuantity && batch.totalQuantity > 0
          ? ((batch.totalQuantity - (batch.soldQuantity || 0)) /
              batch.totalQuantity) *
              100 <
            20
          : false,
      isOutOfStock: (batch.totalQuantity || 0) - (batch.soldQuantity || 0) <= 0,
    };

    res.status(201).json({ data: response, message: "Batch created" });
  }

  async update(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const {
      supplierId,
      purchaseDate,
      totalQuantity,
      totalCost,
      unitCost,
      notes,
      itemId, // Optional: if provided and quantity changed, adjust item stock
    } = req.body;

    // @ts-ignore
    const existingBatch = await prisma.batch.findUnique({
      where: { id: parseInt(id) },
      include: { serials: true },
    });
    if (!existingBatch) throw new AppError(404, "Batch not found");

    // Check if we can update quantity (can't reduce below sold quantity)
    if (totalQuantity !== undefined) {
      const soldQuantity = existingBatch.soldQuantity || 0;
      if (totalQuantity < soldQuantity) {
        throw new AppError(
          400,
          `Cannot reduce quantity below sold quantity (${soldQuantity})`
        );
      }
    }

    // @ts-ignore
    const batch = await prisma.batch.update({
      where: { id: parseInt(id) },
      data: {
        // We intentionally do not allow updating the batchNumber once created
        ...(supplierId !== undefined && { supplierId }),
        ...(purchaseDate !== undefined && {
          purchaseDate: new Date(purchaseDate),
        }),
        ...(totalQuantity !== undefined && { totalQuantity }),
        ...(totalCost !== undefined && { totalCost }),
        ...(unitCost !== undefined && { unitCost }),
        ...(notes !== undefined && { notes }),
      },
      include: { supplier: true, serials: true },
    });

    // Adjust item stock if itemId is provided and quantity changed
    if (
      itemId &&
      totalQuantity !== undefined &&
      totalQuantity !== existingBatch.totalQuantity
    ) {
      const quantityDifference = totalQuantity - existingBatch.totalQuantity;
      await prisma.item.update({
        where: { id: parseInt(itemId) },
        data: {
          stockQuantity: {
            increment: quantityDifference,
          },
        },
      });
    }

    const response = {
      batch: {
        id: batch.id,
        batchNumber: batch.batchNumber,
        supplierId: batch.supplierId,
        purchaseDate: batch.purchaseDate.toISOString(),
        totalQuantity: batch.totalQuantity,
        soldQuantity: batch.soldQuantity,
        unitCost: batch.unitCost,
        totalCost: batch.totalCost,
        notes: batch.notes,
        createdAt: batch.createdAt.toISOString(),
        updatedAt: batch.updatedAt.toISOString(),
      },
      remainingStock: Math.max(
        0,
        (batch.totalQuantity || 0) - (batch.soldQuantity || 0)
      ),
      stockPercentage:
        batch.totalQuantity && batch.totalQuantity > 0
          ? ((batch.totalQuantity - (batch.soldQuantity || 0)) /
              batch.totalQuantity) *
            100
          : 0,
      isLowStock:
        batch.totalQuantity && batch.totalQuantity > 0
          ? ((batch.totalQuantity - (batch.soldQuantity || 0)) /
              batch.totalQuantity) *
              100 <
            20
          : false,
      isOutOfStock: (batch.totalQuantity || 0) - (batch.soldQuantity || 0) <= 0,
    };

    res.json({ data: response, message: "Batch updated" });
  }

  async delete(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { itemId } = req.query; // Optional: if provided, adjust item stock

    // @ts-ignore
    const existingBatch = await prisma.batch.findUnique({
      where: { id: parseInt(id) },
      include: { serials: true },
    });
    if (!existingBatch) throw new AppError(404, "Batch not found");

    // Check if batch has been sold
    if ((existingBatch.soldQuantity || 0) > 0) {
      throw new AppError(400, "Cannot delete batch that has sold items");
    }

    // Check if batch has serials
    if (existingBatch.serials && existingBatch.serials.length > 0) {
      throw new AppError(
        400,
        "Cannot delete batch that has associated serials"
      );
    }

    // Adjust item stock if itemId is provided (subtract remaining quantity)
    if (itemId) {
      const remainingQuantity =
        existingBatch.totalQuantity - (existingBatch.soldQuantity || 0);
      if (remainingQuantity > 0) {
        await prisma.item.update({
          where: { id: parseInt(itemId) },
          data: {
            stockQuantity: {
              decrement: remainingQuantity,
            },
          },
        });
      }
    }

    // @ts-ignore
    await prisma.batch.delete({
      where: { id: parseInt(id) },
    });

    res.json({ message: "Batch deleted" });
  }

  async getForItem(req: AuthRequest, res: Response) {
    const { itemId } = req.params;
    if (!itemId) throw new AppError(400, "Item id required");

    // Find batches that contain serials for the given item
    // @ts-ignore
    const batches = await prisma.batch.findMany({
      where: { serials: { some: { itemId: parseInt(itemId as string) } } },
      include: { supplier: true, serials: true },
    });

    const mapped = batches.map((b: any) => ({
      batch: {
        id: b.id,
        batchNumber: b.batchNumber,
        supplierId: b.supplierId,
        purchaseDate: b.purchaseDate.toISOString(),
        totalQuantity: b.totalQuantity,
        soldQuantity: b.soldQuantity,
        unitCost: b.unitCost,
        totalCost: b.totalCost,
        notes: b.notes,
        createdAt: b.createdAt.toISOString(),
        updatedAt: b.updatedAt.toISOString(),
      },
      remainingStock: Math.max(
        0,
        (b.totalQuantity || 0) - (b.soldQuantity || 0)
      ),
      stockPercentage:
        b.totalQuantity && b.totalQuantity > 0
          ? ((b.totalQuantity - (b.soldQuantity || 0)) / b.totalQuantity) * 100
          : 0,
      isLowStock:
        b.totalQuantity && b.totalQuantity > 0
          ? ((b.totalQuantity - (b.soldQuantity || 0)) / b.totalQuantity) *
              100 <
            20
          : false,
      isOutOfStock: (b.totalQuantity || 0) - (b.soldQuantity || 0) <= 0,
    }));

    res.json({ data: mapped });
  }
}
