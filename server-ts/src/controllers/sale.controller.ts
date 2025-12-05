import { Response } from "express";
import { AppError } from "../middleware/errorHandler";
import { AuthRequest } from "../middleware/auth";
import { prisma } from "../utils/prisma";

export class SaleController {
  async getAll(req: AuthRequest, res: Response) {
    const { page = "1", limit = "50", status, customerId } = req.query;
    const skip = (parseInt(page as string) - 1) * parseInt(limit as string);

    const where: any = {};
    if (status) where.status = status;
    if (customerId) where.customerId = parseInt(customerId as string);

    const [sales, total] = await Promise.all([
      prisma.sale.findMany({
        where,
        skip,
        take: parseInt(limit as string),
        include: {
          customer: true,
          items: {
            include: {
              item: true,
            },
          },
          payments: {
            include: {
              paymentMethod: true,
            },
          },
          paymentAllocations: {
            include: {
              payment: {
                include: {
                  paymentMethod: true,
                },
              },
            },
          },
        },
        orderBy: { saleDate: "desc" },
      }),
      prisma.sale.count({ where }),
    ]);

    res.json({
      data: sales,
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

    const sale = await prisma.sale.findUnique({
      where: { id: parseInt(id) },
      include: {
        customer: true,
        items: {
          include: {
            item: {
              include: {
                category: true,
                condition: true,
                quality: true,
              },
            },
          },
        },
        payments: {
          include: {
            paymentMethod: true,
          },
        },
      },
    });

    if (!sale) {
      throw new AppError(404, "Sale not found");
    }

    res.json({ data: sale });
  }

  async create(req: AuthRequest, res: Response) {
    const { customerId, items, discountType, discountValue, taxRate, notes } =
      req.body;

    if (!items || items.length === 0) {
      throw new AppError(400, "At least one item is required");
    }

    // Generate sale number
    const count = await prisma.sale.count();
    const saleNumber = `SALE-${new Date().getFullYear()}-${String(
      count + 1
    ).padStart(4, "0")}`;

    // Calculate totals
    let subtotal = 0;
    const saleItems = [];

    for (const item of items) {
      const dbItem = await prisma.item.findUnique({
        where: { id: item.itemId },
      });

      if (!dbItem) {
        throw new AppError(404, `Item with ID ${item.itemId} not found`);
      }

      if (dbItem.stockQuantity < item.quantity) {
        throw new AppError(400, `Insufficient stock for item: ${dbItem.name}`);
      }

      const itemTotal = item.unitPrice * item.quantity - (item.discount || 0);
      subtotal += itemTotal;

      saleItems.push({
        itemId: item.itemId,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        discount: item.discount || 0,
        total: itemTotal,
      });
    }

    // Calculate discount
    let discountAmount = 0;
    if (discountType === "percentage" && discountValue) {
      discountAmount = subtotal * (discountValue / 100);
    } else if (discountType === "fixed" && discountValue) {
      discountAmount = discountValue;
    }

    // Calculate tax
    const taxAmount = (subtotal - discountAmount) * (taxRate || 0);
    const totalAmount = subtotal - discountAmount + taxAmount;

    const sale = await prisma.sale.create({
      data: {
        saleNumber,
        customerId,
        status: "draft",
        paymentStatus: "pending",
        subtotal,
        discountType,
        discountValue: discountValue || 0,
        discountAmount,
        taxRate: taxRate || 0,
        taxAmount,
        totalAmount,
        notes,
        items: {
          create: saleItems,
        },
      },
      include: {
        customer: true,
        items: {
          include: {
            item: true,
          },
        },
      },
    });

    res.status(201).json({ data: sale, message: "Sale created successfully" });
  }

  async update(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { notes, status } = req.body;

    const sale = await prisma.sale.findUnique({
      where: { id: parseInt(id) },
    });

    if (!sale) {
      throw new AppError(404, "Sale not found");
    }

    const updated = await prisma.sale.update({
      where: { id: parseInt(id) },
      data: { notes, status },
      include: {
        customer: true,
        items: {
          include: {
            item: true,
          },
        },
        payments: {
          include: {
            paymentMethod: true,
          },
        },
      },
    });

    res.json({ data: updated, message: "Sale updated successfully" });
  }

  async updateStatus(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { status } = req.body;

    if (!status) {
      throw new AppError(400, "Status is required");
    }

    const sale = await prisma.sale.findUnique({
      where: { id: parseInt(id) },
      include: {
        items: true,
      },
    });

    if (!sale) {
      throw new AppError(404, "Sale not found");
    }

    // Reduce stock when confirming sale with batch-aware accounting
    if (status === "confirmed" && sale.status === "draft") {
      let totalCogs = 0;

      for (const saleItem of sale.items) {
        const item = await prisma.item.findUnique({
          where: { id: saleItem.itemId },
          include: { serials: { include: { batch: true } } },
        });

        if (!item) continue;

        let remainingQuantity = saleItem.quantity;
        let itemCogs = 0;

        // Sort serials by batch purchase date (FIFO)
        const availableSerials = item.serials
          .filter((s) => s.status === "available")
          .sort(
            (a, b) =>
              a.batch.purchaseDate.getTime() - b.batch.purchaseDate.getTime()
          );

        // Process serials for this item
        for (const serial of availableSerials) {
          if (remainingQuantity <= 0) break;

          // Mark serial as sold and link to saleItem
          await prisma.serial.update({
            where: { id: serial.id },
            data: {
              status: "sold",
              saleItemId: saleItem.id,
            },
          });

          // Update batch sold quantity
          await prisma.batch.update({
            where: { id: serial.batchId },
            data: {
              soldQuantity: { increment: 1 },
            },
          });

          // Create SaleItemBatch record
          await prisma.saleItemBatch.create({
            data: {
              saleItemId: saleItem.id,
              batchId: serial.batchId,
              quantity: 1,
            },
          });

          // Add to COGS
          itemCogs += serial.batch.unitCost;
          totalCogs += serial.batch.unitCost;

          remainingQuantity--;
        }

        // If item doesn't have enough serials or is not phone type, handle remaining stock
        if (remainingQuantity > 0) {
          // For non-phone items, find batches with available quantity
          // We need to find batches that have (totalQuantity - soldQuantity) > 0
          // and sort by purchaseDate (FIFO)
          const batches = await prisma.batch.findMany({
            where: {
              itemId: saleItem.itemId,
              soldQuantity: { lt: prisma.batch.fields.totalQuantity },
            },
            orderBy: { purchaseDate: "asc" }, // FIFO
          });

          for (const batch of batches) {
            if (remainingQuantity <= 0) break;

            const availableInBatch = batch.totalQuantity - batch.soldQuantity;
            const takeFromBatch = Math.min(remainingQuantity, availableInBatch);

            // Update batch
            await prisma.batch.update({
              where: { id: batch.id },
              data: { soldQuantity: { increment: takeFromBatch } },
            });

            // Create SaleItemBatch
            await prisma.saleItemBatch.create({
              data: {
                saleItemId: saleItem.id,
                batchId: batch.id,
                quantity: takeFromBatch,
              },
            });

            itemCogs += batch.unitCost * takeFromBatch;
            totalCogs += batch.unitCost * takeFromBatch;
            remainingQuantity -= takeFromBatch;
          }

          // If still remaining (no batches found or insufficient), fall back to average cost logic (legacy/fallback)
          if (remainingQuantity > 0) {
            // ... (keep existing fallback logic if needed, or just log warning)
            // For now, we will just decrement stock and assume 0 cost or last known cost if strictly enforcing batches isn't possible yet
            // But ideally we should have batches for everything.
            // Let's keep the stock decrement for consistency with `Item` model
          }

          // Reduce general stock
          await prisma.item.update({
            where: { id: saleItem.itemId },
            data: {
              stockQuantity: {
                decrement: saleItem.quantity, // Decrement full quantity from item master
              },
            },
          });
        } else {
          // Update item stock quantity based on available serials
          const availableCount =
            item.serials.filter((s) => s.status === "available").length -
            saleItem.quantity;
          await prisma.item.update({
            where: { id: saleItem.itemId },
            data: {
              stockQuantity: Math.max(0, availableCount),
            },
          });
        }

        // Log stock usage with cost
        await prisma.stockUsage.create({
          data: {
            itemId: saleItem.itemId,
            quantity: saleItem.quantity,
            unitCost: itemCogs / saleItem.quantity, // Average cost per unit
            reason: `Sale ${sale.saleNumber}`,
          },
        });
      }

      // Update sale with COGS and profit
      const profit = sale.totalAmount - totalCogs;
      await prisma.sale.update({
        where: { id: parseInt(id) },
        data: {
          cogs: totalCogs,
          profit: profit,
        },
      });
    } else if (
      (status === "refunded" || status === "cancelled") &&
      (sale.status === "confirmed" ||
        sale.status === "paid" ||
        sale.status === "partial")
    ) {
      // Return items to stock
      for (const saleItem of sale.items) {
        // Restore batches
        const batches = await prisma.saleItemBatch.findMany({
          where: { saleItemId: saleItem.id },
        });

        for (const batchRecord of batches) {
          await prisma.batch.update({
            where: { id: batchRecord.batchId },
            data: { soldQuantity: { decrement: batchRecord.quantity } },
          });
        }

        // Restore serials
        await prisma.serial.updateMany({
          where: { saleItemId: saleItem.id },
          data: { status: "available", saleItemId: null },
        });

        // Restore item stock
        await prisma.item.update({
          where: { id: saleItem.itemId },
          data: { stockQuantity: { increment: saleItem.quantity } },
        });

        // Delete SaleItemBatch records to prevent double refunding if status toggles?
        // Or keep them for history? If we keep them, we need to make sure we don't process them again.
        // But status transition from refunded -> confirmed is unlikely/complex.
        // Let's delete them to be safe and clean.
        await prisma.saleItemBatch.deleteMany({
          where: { saleItemId: saleItem.id },
        });
      }
    }

    const updated = await prisma.sale.update({
      where: { id: parseInt(id) },
      data: { status },
      include: {
        customer: true,
        items: {
          include: {
            item: true,
          },
        },
        payments: {
          include: {
            paymentMethod: true,
          },
        },
      },
    });

    res.json({ data: updated, message: "Sale status updated successfully" });
  }

  async delete(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const sale = await prisma.sale.findUnique({
      where: { id: parseInt(id) },
      include: { items: true },
    });

    if (!sale) {
      throw new AppError(404, "Sale not found");
    }

    if (
      sale.status === "confirmed" ||
      sale.status === "paid" ||
      sale.status === "partial"
    ) {
      // Return items to stock
      for (const saleItem of sale.items) {
        // 1. Restore from SaleItemBatch
        const batches = await prisma.saleItemBatch.findMany({
          where: { saleItemId: saleItem.id },
        });

        for (const batchRecord of batches) {
          await prisma.batch.update({
            where: { id: batchRecord.batchId },
            data: { soldQuantity: { decrement: batchRecord.quantity } },
          });
        }

        // 2. Restore Serials
        await prisma.serial.updateMany({
          where: { saleItemId: saleItem.id },
          data: { status: "available", saleItemId: null },
        });

        // 3. Restore Item Stock
        await prisma.item.update({
          where: { id: saleItem.itemId },
          data: { stockQuantity: { increment: saleItem.quantity } },
        });
      }
    }

    // Delete the sale (cascades should handle items, payments, allocations, saleItemBatches)
    await prisma.sale.delete({
      where: { id: parseInt(id) },
    });

    res.json({
      message: "Sale deleted and items returned to stock successfully",
    });
  }

  async createPayment(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { paymentMethodId, amount, referenceNumber, paymentDate, notes } =
      req.body;

    if (!paymentMethodId || !amount) {
      throw new AppError(400, "paymentMethodId and amount are required");
    }

    const sale = await prisma.sale.findUnique({ where: { id: parseInt(id) } });
    if (!sale) {
      throw new AppError(404, "Sale not found");
    }
    await prisma.sale.update({
      where: { id: parseInt(id) },
      data: {
        status: "Confirmed",
      },
    });
    const payment = await prisma.payment.create({
      data: {
        saleId: parseInt(id),
        paymentMethodId: paymentMethodId,
        amount: amount,
        referenceNumber: referenceNumber || null,
        notes: notes || null,
        paymentDate: paymentDate ? new Date(paymentDate) : new Date(),
      },
      include: { paymentMethod: true },
    });

    // Update sale payment status
    const totalPaidResult = await prisma.payment.aggregate({
      where: { saleId: parseInt(id) },
      _sum: { amount: true },
    });
    const totalPaid = totalPaidResult._sum.amount || 0;
    const saleRecord = await prisma.sale.findUnique({
      where: { id: parseInt(id) },
    });
    if (saleRecord) {
      const paymentStatus =
        totalPaid >= saleRecord.totalAmount
          ? "paid"
          : totalPaid > 0
          ? "partial"
          : "pending";

      await prisma.sale.update({
        where: { id: parseInt(id) },
        data: { paymentStatus },
      });
    }

    // Return the created payment (including paymentMethod)
    res
      .status(201)
      .json({ data: payment, message: "Payment added successfully" });
  }

  async getDailyReport(req: AuthRequest, res: Response) {
    const { date } = req.query;
    const targetDate = date ? new Date(date as string) : new Date();

    const startOfDay = new Date(targetDate.setHours(0, 0, 0, 0));
    const endOfDay = new Date(targetDate.setHours(23, 59, 59, 999));

    const sales = await prisma.sale.findMany({
      where: {
        saleDate: {
          gte: startOfDay,
          lte: endOfDay,
        },
        status: { not: "cancelled" },
      },
      include: {
        items: true,
        payments: {
          include: {
            paymentMethod: true,
          },
        },
      },
    });

    const totalSales = sales.reduce(
      (sum: number, sale: any) => sum + sale.totalAmount,
      0
    );
    const totalOrders = sales.length;

    const paymentBreakdown = sales
      .flatMap((s: any) => s.payments)
      .reduce((acc: Record<string, number>, payment: any) => {
        const method = payment.paymentMethod.name;
        if (!acc[method]) {
          acc[method] = 0;
        }
        acc[method] += payment.amount;
        return acc;
      }, {});

    res.json({
      data: {
        date: startOfDay,
        totalSales,
        totalOrders,
        paymentBreakdown,
        sales,
      },
    });
  }

  async getMonthlyReport(req: AuthRequest, res: Response) {
    const { year, month } = req.query;
    const targetYear = year
      ? parseInt(year as string)
      : new Date().getFullYear();
    const targetMonth = month
      ? parseInt(month as string) - 1
      : new Date().getMonth();

    const startOfMonth = new Date(targetYear, targetMonth, 1);
    const endOfMonth = new Date(
      targetYear,
      targetMonth + 1,
      0,
      23,
      59,
      59,
      999
    );

    const sales = await prisma.sale.findMany({
      where: {
        saleDate: {
          gte: startOfMonth,
          lte: endOfMonth,
        },
        status: { not: "cancelled" },
      },
      include: {
        items: {
          include: {
            item: true,
          },
        },
        payments: {
          include: {
            paymentMethod: true,
          },
        },
      },
    });

    const totalSales = sales.reduce((sum, sale) => sum + sale.totalAmount, 0);
    const totalOrders = sales.length;

    res.json({
      data: {
        year: targetYear,
        month: targetMonth + 1,
        totalSales,
        totalOrders,
        sales,
      },
    });
  }
}
