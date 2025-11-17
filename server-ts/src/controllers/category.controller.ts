import { Response } from "express";
import { validationResult } from "express-validator";
import { AppError } from "../middleware/errorHandler";
import { AuthRequest } from "../middleware/auth";
import { prisma } from "../utils/prisma";

export class CategoryController {
  async getAll(_req: AuthRequest, res: Response) {
    const categories = await prisma.category.findMany({
      include: {
        parent: true,
        children: true,
        _count: {
          select: { items: true },
        },
      },
      orderBy: { name: "asc" },
    });

    res.json({ data: categories });
  }

  async getById(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const category = await prisma.category.findUnique({
      where: { id: parseInt(id) },
      include: {
        parent: true,
        children: true,
        items: true,
      },
    });

    if (!category) {
      throw new AppError(404, "Category not found");
    }

    res.json({ data: category });
  }

  async create(req: AuthRequest, res: Response) {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw new AppError(400, errors.array()[0].msg);
    }

    const { name, description, parentId } = req.body;

    // Check if parent exists
    if (parentId) {
      const parent = await prisma.category.findUnique({
        where: { id: parentId },
      });
      if (!parent) {
        throw new AppError(404, "Parent category not found");
      }
    }

    const category = await prisma.category.create({
      data: {
        name,
        description,
        parentId,
      },
      include: {
        parent: true,
      },
    });

    res
      .status(201)
      .json({ data: category, message: "Category created successfully" });
  }

  async update(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { name, description, parentId } = req.body;

    const category = await prisma.category.findUnique({
      where: { id: parseInt(id) },
    });

    if (!category) {
      throw new AppError(404, "Category not found");
    }

    // Prevent circular reference
    if (parentId && parentId === parseInt(id)) {
      throw new AppError(400, "Category cannot be its own parent");
    }

    const updated = await prisma.category.update({
      where: { id: parseInt(id) },
      data: {
        name,
        description,
        parentId,
      },
      include: {
        parent: true,
      },
    });

    res.json({ data: updated, message: "Category updated successfully" });
  }

  async delete(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const category = await prisma.category.findUnique({
      where: { id: parseInt(id) },
      include: {
        _count: {
          select: { items: true, children: true },
        },
      },
    });

    if (!category) {
      throw new AppError(404, "Category not found");
    }

    if (category._count.items > 0) {
      throw new AppError(400, "Cannot delete category with associated items");
    }

    if (category._count.children > 0) {
      throw new AppError(400, "Cannot delete category with subcategories");
    }

    await prisma.category.delete({
      where: { id: parseInt(id) },
    });

    res.json({ message: "Category deleted successfully" });
  }
}
