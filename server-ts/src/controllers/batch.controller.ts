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
      batch: b,
      remaining_stock: Math.max(
        0,
        (b.totalQuantity || 0) - (b.soldQuantity || 0)
      ),
      stock_percentage:
        b.totalQuantity && b.totalQuantity > 0
          ? ((b.totalQuantity - (b.soldQuantity || 0)) / b.totalQuantity) * 100
          : 0,
      is_low_stock:
        b.totalQuantity && b.totalQuantity > 0
          ? ((b.totalQuantity - (b.soldQuantity || 0)) / b.totalQuantity) *
              100 <
            20
          : false,
      is_out_of_stock: (b.totalQuantity || 0) - (b.soldQuantity || 0) <= 0,
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
      batch,
      remaining_stock: Math.max(
        0,
        (batch.totalQuantity || 0) - (batch.soldQuantity || 0)
      ),
      stock_percentage:
        batch.totalQuantity && batch.totalQuantity > 0
          ? ((batch.totalQuantity - (batch.soldQuantity || 0)) /
              batch.totalQuantity) *
            100
          : 0,
      is_low_stock:
        batch.totalQuantity && batch.totalQuantity > 0
          ? ((batch.totalQuantity - (batch.soldQuantity || 0)) /
              batch.totalQuantity) *
              100 <
            20
          : false,
      is_out_of_stock:
        (batch.totalQuantity || 0) - (batch.soldQuantity || 0) <= 0,
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
    } = req.body;

    if (
      !batchNumber ||
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

    // @ts-ignore
    const batch = await prisma.batch.create({
      data: {
        batchNumber,
        supplierId,
        purchaseDate: purchaseDate ? new Date(purchaseDate) : new Date(),
        totalQuantity,
        totalCost,
        unitCost,
        notes,
      },
      include: { supplier: true, serials: true },
    });

    const response = {
      batch,
      remaining_stock: Math.max(
        0,
        (batch.totalQuantity || 0) - (batch.soldQuantity || 0)
      ),
      stock_percentage:
        batch.totalQuantity && batch.totalQuantity > 0
          ? ((batch.totalQuantity - (batch.soldQuantity || 0)) /
              batch.totalQuantity) *
            100
          : 0,
      is_low_stock:
        batch.totalQuantity && batch.totalQuantity > 0
          ? ((batch.totalQuantity - (batch.soldQuantity || 0)) /
              batch.totalQuantity) *
              100 <
            20
          : false,
      is_out_of_stock:
        (batch.totalQuantity || 0) - (batch.soldQuantity || 0) <= 0,
    };

    res.status(201).json({ data: response, message: "Batch created" });
  }

  async update(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const {
      batchNumber,
      supplierId,
      purchaseDate,
      totalQuantity,
      totalCost,
      unitCost,
      notes,
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
        ...(batchNumber !== undefined && { batchNumber }),
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

    const response = {
      batch,
      remaining_stock: Math.max(
        0,
        (batch.totalQuantity || 0) - (batch.soldQuantity || 0)
      ),
      stock_percentage:
        batch.totalQuantity && batch.totalQuantity > 0
          ? ((batch.totalQuantity - (batch.soldQuantity || 0)) /
              batch.totalQuantity) *
            100
          : 0,
      is_low_stock:
        batch.totalQuantity && batch.totalQuantity > 0
          ? ((batch.totalQuantity - (batch.soldQuantity || 0)) /
              batch.totalQuantity) *
              100 <
            20
          : false,
      is_out_of_stock:
        (batch.totalQuantity || 0) - (batch.soldQuantity || 0) <= 0,
    };

    res.json({ data: response, message: "Batch updated" });
  }

  async delete(req: AuthRequest, res: Response) {
    const { id } = req.params;

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
      batch: b,
      remaining_stock: Math.max(
        0,
        (b.totalQuantity || 0) - (b.soldQuantity || 0)
      ),
      stock_percentage:
        b.totalQuantity && b.totalQuantity > 0
          ? ((b.totalQuantity - (b.soldQuantity || 0)) / b.totalQuantity) * 100
          : 0,
      is_low_stock:
        b.totalQuantity && b.totalQuantity > 0
          ? ((b.totalQuantity - (b.soldQuantity || 0)) / b.totalQuantity) *
              100 <
            20
          : false,
      is_out_of_stock: (b.totalQuantity || 0) - (b.soldQuantity || 0) <= 0,
    }));

    res.json({ data: mapped });
  }
}
