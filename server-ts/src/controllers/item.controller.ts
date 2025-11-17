import { Response } from "express";
import { AppError } from "../middleware/errorHandler";
import { AuthRequest } from "../middleware/auth";
import { prisma } from "../utils/prisma";
import type { Item } from "@prisma/client";

export class ItemController {
  async getAll(req: AuthRequest, res: Response) {
    const {
      page = "1",
      limit = "50",
      categoryId,
      batchId,
      lowStock,
    } = req.query;
    const skip = (parseInt(page as string) - 1) * parseInt(limit as string);

    const where: any = {};
    if (categoryId) where.categoryId = parseInt(categoryId as string);
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
          batch: true,
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
            batch: true,
          },
          orderBy: { name: "asc" },
        }),
        prisma.item.count({ where }),
      ]);
    }

    res.json({
      data: items,
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

    const items = await prisma.item.findMany({
      where: {
        OR: [
          { name: { contains: q as string } },
          { brand: { contains: q as string } },
          { model: { contains: q as string } },
          { imei: { contains: q as string } },
        ],
      },
      include: {
        category: true,
        condition: true,
        quality: true,
        batch: true,
      },
      take: 50,
    });

    res.json({ data: items });
  }

  async getLowStock(_req: AuthRequest, res: Response) {
    const allItems = await prisma.item.findMany({
      include: {
        category: true,
        condition: true,
        quality: true,
      },
      orderBy: { stockQuantity: "asc" },
    });

    const items = allItems.filter(
      (it: Item) => it.stockQuantity <= it.minStockLevel
    );

    res.json({ data: items });
  }

  async getById(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const item = await prisma.item.findUnique({
      where: { id: parseInt(id) },
      include: {
        category: true,
        condition: true,
        quality: true,
        batch: {
          include: {
            supplier: true,
          },
        },
      },
    });

    if (!item) {
      throw new AppError(404, "Item not found");
    }

    res.json({ data: item });
  }

  async create(req: AuthRequest, res: Response) {
    const {
      name,
      categoryId,
      brand,
      model,
      imei,
      description,
      conditionId,
      qualityId,
      stockQuantity,
      minStockLevel,
      unitCost,
      sellingPrice,
      batchId,
    } = req.body;

    if (
      !name ||
      !categoryId ||
      !conditionId ||
      !qualityId ||
      unitCost === undefined ||
      sellingPrice === undefined
    ) {
      throw new AppError(400, "Required fields missing");
    }

    // Check IMEI uniqueness
    if (imei) {
      const existing = await prisma.item.findUnique({
        where: { imei },
      });
      if (existing) {
        throw new AppError(409, "Item with this IMEI already exists");
      }
    }

    const item = await prisma.item.create({
      data: {
        name,
        categoryId,
        brand,
        model,
        imei,
        description,
        conditionId,
        qualityId,
        stockQuantity: stockQuantity || 0,
        minStockLevel: minStockLevel || 5,
        unitCost,
        sellingPrice,
        batchId,
      },
      include: {
        category: true,
        condition: true,
        quality: true,
        batch: true,
      },
    });

    res.status(201).json({ data: item, message: "Item created successfully" });
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

    // Check IMEI uniqueness
    if (data.imei && data.imei !== item.imei) {
      const existing = await prisma.item.findUnique({
        where: { imei: data.imei },
      });
      if (existing) {
        throw new AppError(409, "IMEI already exists");
      }
    }

    const updated = await prisma.item.update({
      where: { id: parseInt(id) },
      data,
      include: {
        category: true,
        condition: true,
        quality: true,
        batch: true,
      },
    });

    res.json({ data: updated, message: "Item updated successfully" });
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
      },
    });

    // Log stock usage if needed
    if (reason) {
      await prisma.stockUsage.create({
        data: {
          itemId: parseInt(id),
          quantity,
          unitCost: item.unitCost,
          reason,
        },
      });
    }

    res.json({ data: updated, message: "Stock adjusted successfully" });
  }
}
