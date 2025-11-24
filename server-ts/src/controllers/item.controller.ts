import { Response } from "express";
import { AppError } from "../middleware/errorHandler";
import { AuthRequest } from "../middleware/auth";
import { prisma } from "../utils/prisma";
import type { Item } from "@prisma/client";

// Transform Prisma item to snake_case for mobile client
function transformItemToSnakeCase(item: any) {
  return {
    ...item,
    category_id: item.categoryId,
    condition_id: item.conditionId,
    quality_id: item.qualityId,
    item_type: item.itemType,
    stock_quantity: item.stockQuantity,
    min_stock_level: item.minStockLevel,
    selling_price: item.sellingPrice,
    created_at: item.createdAt,
    updated_at: item.updatedAt,
  };
}

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
          },
          orderBy: { name: "asc" },
        }),
        prisma.item.count({ where }),
      ]);
    }

    res.json({
      data: items.map(transformItemToSnakeCase),
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

    // Search serials for IMEI matches, map to item ids
    // Note: `serial` model will exist after running `prisma generate`.
    // @ts-ignore - prisma client generated types might not be updated here yet
    const serialMatches = await prisma.serial.findMany({
      where: { imei: { contains: q as string } },
      select: { itemId: true },
    });

    const itemIds = serialMatches.map((s: any) => s.itemId);

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
        serials: true,
      },
    });

    if (!item) {
      throw new AppError(404, "Item not found");
    }

    res.json({ data: transformItemToSnakeCase(item) });
  }

  async create(req: AuthRequest, res: Response) {
    // Support both camelCase and snake_case from client
    const {
      name,
      categoryId,
      category_id,
      brand,
      model,
      description,
      conditionId,
      condition_id,
      qualityId,
      quality_id,
      itemType,
      item_type,
      stockQuantity,
      stock_quantity,
      minStockLevel,
      min_stock_level,
      sellingPrice,
      selling_price,
    } = req.body;

    // Use snake_case first (mobile convention), fallback to camelCase
    const finalCategoryId = category_id || categoryId;
    const finalConditionId = condition_id || conditionId;
    const finalQualityId = quality_id || qualityId;
    const finalItemType = item_type || itemType || "other";
    const finalStockQuantity =
      stock_quantity !== undefined ? stock_quantity : stockQuantity;
    const finalMinStockLevel =
      min_stock_level !== undefined ? min_stock_level : minStockLevel;
    const finalSellingPrice =
      selling_price !== undefined ? selling_price : sellingPrice;

    if (
      !name ||
      !finalCategoryId ||
      !finalConditionId ||
      !finalQualityId ||
      finalSellingPrice === undefined
    ) {
      console.log({
        name,
        categoryId: finalCategoryId,
        conditionId: finalConditionId,
        qualityId: finalQualityId,
        sellingPrice: finalSellingPrice,
      });
      throw new AppError(400, "Required fields missing");
    }

    const item = await prisma.item.create({
      data: {
        name,
        categoryId: finalCategoryId,
        brand,
        model,
        description,
        conditionId: finalConditionId,
        qualityId: finalQualityId,
        itemType: finalItemType,
        stockQuantity: finalStockQuantity || 0,
        minStockLevel: finalMinStockLevel || 5,
        sellingPrice: finalSellingPrice,
      },
      include: {
        category: true,
        condition: true,
        quality: true,
      },
    });

    res.status(201).json({
      data: transformItemToSnakeCase(item),
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

    // IMEI moved to Serial model - uniqueness enforcement should be done via serial endpoints

    const updated = await prisma.item.update({
      where: { id: parseInt(id) },
      data,
      include: {
        category: true,
        condition: true,
        quality: true,
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
      // TODO: Track batch-specific cost when implementing batch deduction
      await prisma.stockUsage.create({
        data: {
          itemId: parseInt(id),
          quantity,
          unitCost: 0, // Will be updated when batch tracking is implemented
          reason,
        },
      });
    }

    res.json({ data: updated, message: "Stock adjusted successfully" });
  }
}
