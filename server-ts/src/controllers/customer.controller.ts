import { Response } from "express";
import { AppError } from "../middleware/errorHandler";
import { AuthRequest } from "../middleware/auth";
import { prisma } from "../utils/prisma";

export class CustomerController {
  async getAll(req: AuthRequest, res: Response) {
    const { page = "1", limit = "50", search } = req.query;
    console.log("getAll query params:", req.query);
    const skip = (parseInt(page as string) - 1) * parseInt(limit as string);

    const where: any = {};

    if (search) {
      console.log("Searching for:", search);
      where.OR = [
        { name: { contains: search as string } },
        { phone: { contains: search as string } },
        { email: { contains: search as string } },
        { companyName: { contains: search as string } },
      ];
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

    console.log(`Found ${customers.length} customers out of ${total} total`);

    // Transform to camelCase
    const transformedCustomers = customers.map((customer) => ({
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      companyName: customer.companyName,
      type: customer.type,
      locationLink: customer.locationLink,
      taxNumber: customer.taxNumber,
      createdAt: customer.createdAt.toISOString(),
      updatedAt: customer.updatedAt.toISOString(),
    }));

    res.json({
      data: transformedCustomers,
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

    // Transform to camelCase
    const transformedCustomers = customers.map((customer) => ({
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      companyName: customer.companyName,
      type: customer.type,
      locationLink: customer.locationLink,
      taxNumber: customer.taxNumber,
      createdAt: customer.createdAt.toISOString(),
      updatedAt: customer.updatedAt.toISOString(),
    }));

    res.json({ data: transformedCustomers });
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

    // Transform to camelCase
    const responseData = {
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      companyName: customer.companyName,
      type: customer.type,
      locationLink: customer.locationLink,
      createdAt: customer.createdAt.toISOString(),
      updatedAt: customer.updatedAt.toISOString(),
    };

    res.json({ data: responseData });
  }

  async create(req: AuthRequest, res: Response) {
    console.log("Creating customer with body:", req.body);
    const {
      name,
      phone,
      email,
      address,
      companyName,
      type,
      locationLink,
      taxNumber,
    } = req.body;
    console.log("Extracted name:", name, "phone:", phone);
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
        taxNumber,
      },
    });

    console.log("Created customer:", customer.name);

    // Transform to camelCase for response
    const responseData = {
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      companyName: customer.companyName,
      type: customer.type,
      locationLink: customer.locationLink,
      taxNumber: customer.taxNumber,
      createdAt: customer.createdAt.toISOString(),
      updatedAt: customer.updatedAt.toISOString(),
    };

    res
      .status(201)
      .json({ data: responseData, message: "Customer created successfully" });
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
        ...(name !== undefined && { name }),
        ...(phone !== undefined && { phone }),
        ...(email !== undefined && { email }),
        ...(address !== undefined && { address }),
        ...(companyName !== undefined && { companyName }),
        ...(type !== undefined && { type }),
        ...(locationLink !== undefined && { locationLink }),
      },
    });

    // Transform to camelCase
    const responseData = {
      id: updated.id,
      name: updated.name,
      phone: updated.phone,
      email: updated.email,
      address: updated.address,
      companyName: updated.companyName,
      type: updated.type,
      locationLink: updated.locationLink,
      createdAt: updated.createdAt.toISOString(),
      updatedAt: updated.updatedAt.toISOString(),
    };

    res.json({ data: responseData, message: "Customer updated successfully" });
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

  async getLedger(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { startDate, endDate } = req.query;
    const customerId = parseInt(id);

    const [repairs, sales, payments] = await Promise.all([
      prisma.repair.findMany({
        where: { customerId },
        include: { items: true },
      }),
      prisma.sale.findMany({
        where: { customerId },
      }),
      prisma.payment.findMany({
        where: {
          OR: [
            { customerId },
            { sale: { customerId } },
            { repair: { customerId } },
          ],
        },
        include: { paymentMethod: true },
      }),
    ]);

    const transactions: any[] = [];

    // Add repairs
    repairs.forEach((repair) => {
      // Calculate cost if finalCost is not set
      let amount = repair.finalCost;
      if (amount === null || amount === undefined) {
        const itemsCost = repair.items.reduce(
          (sum, item) => sum + item.totalPrice,
          0
        );
        amount = (repair.serviceCharge || 0) + itemsCost;
      }

      transactions.push({
        id: `R-${repair.id}`,
        date: repair.createdAt,
        type: "Repair",
        reference: repair.repairNumber,
        description: `Repair: ${repair.deviceBrand} ${repair.deviceModel}`,
        debit: amount,
        credit: 0,
        originalObj: repair,
      });
    });

    // Add sales
    sales.forEach((sale) => {
      if (sale.status === "draft" || sale.status === "cancelled") return;

      transactions.push({
        id: `S-${sale.id}`,
        date: sale.saleDate,
        type: "Sale",
        reference: sale.saleNumber,
        description: "Sale",
        debit: sale.totalAmount,
        credit: 0,
        originalObj: sale,
      });
    });

    // Add payments
    payments.forEach((payment) => {
      transactions.push({
        id: `P-${payment.id}`,
        date: payment.paymentDate,
        type: "Payment",
        reference: payment.referenceNumber,
        description: `Payment (${payment.paymentMethod.name})`,
        debit: 0,
        credit: payment.amount,
        originalObj: payment,
      });
    });

    // Sort by date
    transactions.sort(
      (a, b) => new Date(a.date).getTime() - new Date(b.date).getTime()
    );

    // Calculate running balance
    let balance = 0;
    const ledgerWithBalance = transactions.map((t) => {
      balance += t.debit - t.credit;
      return { ...t, balance };
    });

    // Filter by date range if provided
    let filteredLedger = ledgerWithBalance;
    if (startDate) {
      filteredLedger = filteredLedger.filter(
        (t) => new Date(t.date) >= new Date(startDate as string)
      );
    }
    if (endDate) {
      filteredLedger = filteredLedger.filter(
        (t) => new Date(t.date) <= new Date(endDate as string)
      );
    }

    res.json({
      data: filteredLedger,
      summary: {
        totalDebit: transactions.reduce((sum, t) => sum + t.debit, 0),
        totalCredit: transactions.reduce((sum, t) => sum + t.credit, 0),
        finalBalance: balance,
      },
    });
  }
}
