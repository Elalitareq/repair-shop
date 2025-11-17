import { Response } from "express";
import { AppError } from "../middleware/errorHandler";
import { AuthRequest } from "../middleware/auth";
import { prisma } from "../utils/prisma";

export class CustomerController {
  async getAll(req: AuthRequest, res: Response) {
    const { page = "1", limit = "50", type } = req.query;
    const skip = (parseInt(page as string) - 1) * parseInt(limit as string);

    const where: any = {};
    if (type) {
      where.type = type;
    }

    const [customers, total] = await Promise.all([
      prisma.customer.findMany({
        where,
        skip,
        take: parseInt(limit as string),
        orderBy: { name: "asc" },
      }),
      prisma.customer.count({ where }),
    ]);

    res.json({
      data: customers,
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

    const customers = await prisma.customer.findMany({
      where: {
        OR: [
          { name: { contains: q as string } },
          { phone: { contains: q as string } },
          { email: { contains: q as string } },
          { companyName: { contains: q as string } },
        ],
      },
      take: 50,
    });

    res.json({ data: customers });
  }

  async getById(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const customer = await prisma.customer.findUnique({
      where: { id: parseInt(id) },
      include: {
        repairs: {
          orderBy: { createdAt: "desc" },
          take: 10,
        },
        sales: {
          orderBy: { createdAt: "desc" },
          take: 10,
        },
      },
    });

    if (!customer) {
      throw new AppError(404, "Customer not found");
    }

    res.json({ data: customer });
  }

  async create(req: AuthRequest, res: Response) {
    const { name, phone, email, address, companyName, type, locationLink } =
      req.body;

    if (!name || !phone) {
      throw new AppError(400, "Name and phone are required");
    }

    // Check if phone already exists
    const existing = await prisma.customer.findUnique({
      where: { phone },
    });

    if (existing) {
      throw new AppError(409, "Customer with this phone number already exists");
    }

    const customer = await prisma.customer.create({
      data: {
        name,
        phone,
        email,
        address,
        companyName,
        type: type || "customer",
        locationLink,
      },
    });

    res
      .status(201)
      .json({ data: customer, message: "Customer created successfully" });
  }

  async update(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { name, phone, email, address, companyName, type, locationLink } =
      req.body;

    const customer = await prisma.customer.findUnique({
      where: { id: parseInt(id) },
    });

    if (!customer) {
      throw new AppError(404, "Customer not found");
    }

    // Check phone uniqueness
    if (phone && phone !== customer.phone) {
      const existing = await prisma.customer.findUnique({
        where: { phone },
      });
      if (existing) {
        throw new AppError(409, "Phone number already exists");
      }
    }

    const updated = await prisma.customer.update({
      where: { id: parseInt(id) },
      data: {
        name,
        phone,
        email,
        address,
        companyName,
        type,
        locationLink,
      },
    });

    res.json({ data: updated, message: "Customer updated successfully" });
  }

  async delete(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const customer = await prisma.customer.findUnique({
      where: { id: parseInt(id) },
      include: {
        _count: {
          select: { repairs: true, sales: true },
        },
      },
    });

    if (!customer) {
      throw new AppError(404, "Customer not found");
    }

    if (customer._count.repairs > 0 || customer._count.sales > 0) {
      throw new AppError(
        400,
        "Cannot delete customer with associated repairs or sales"
      );
    }

    await prisma.customer.delete({
      where: { id: parseInt(id) },
    });

    res.json({ message: "Customer deleted successfully" });
  }
}
