import { Response } from "express";
import { AppError } from "../middleware/errorHandler";
import { AuthRequest } from "../middleware/auth";
import { prisma } from "../utils/prisma";

export class RepairController {
  async getAll(req: AuthRequest, res: Response) {
    const { page = "1", limit = "50", stateId, customerId } = req.query;
    const skip = (parseInt(page as string) - 1) * parseInt(limit as string);

    const where: any = {};
    if (stateId) where.stateId = parseInt(stateId as string);
    if (customerId) where.customerId = parseInt(customerId as string);

    const [repairs, total] = await Promise.all([
      prisma.repair.findMany({
        where,
        skip,
        take: parseInt(limit as string),
        include: {
          customer: true,
          state: true,
          issues: {
            include: {
              issueType: true,
            },
          },
          items: true,
          statusHistory: true,
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
        orderBy: { receivedDate: "desc" },
      }),
      prisma.repair.count({ where }),
    ]);

    res.json({
      data: repairs,
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

    const repair = await prisma.repair.findUnique({
      where: { id: parseInt(id) },
      include: {
        customer: true,
        state: true,
        issues: {
          include: {
            issueType: true,
          },
        },
        images: true,
        items: {
          include: {
            repairItemBatches: {
              include: {
                batch: true,
              },
            },
          },
        },
        statusHistory: true,
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
    });

    if (!repair) {
      throw new AppError(404, "Repair not found");
    }

    res.json({ data: repair });
  }

  async createPayment(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { paymentMethodId, amount, referenceNumber, paymentDate, notes } =
      req.body;

    if (!paymentMethodId || !amount) {
      throw new AppError(400, "paymentMethodId and amount are required");
    }

    const repair = await prisma.repair.findUnique({
      where: { id: parseInt(id) },
      include: { items: true },
    });

    if (!repair) {
      throw new AppError(404, "Repair not found");
    }

    const payment = await prisma.payment.create({
      data: {
        repairId: parseInt(id),
        paymentMethodId,
        amount,
        referenceNumber: referenceNumber || null,
        notes: notes || null,
        paymentDate: paymentDate ? new Date(paymentDate) : new Date(),
      },
      include: { paymentMethod: true },
    });

    // Update repair payment status
    const totalPaidResult = await prisma.payment.aggregate({
      where: { repairId: parseInt(id) },
      _sum: { amount: true },
    });
    const totalPaid = totalPaidResult._sum.amount || 0;

    const itemsCost = repair.items.reduce(
      (sum, item) => sum + item.totalPrice,
      0
    );
    const totalCost = (repair.serviceCharge || 0) + itemsCost;

    const paymentStatus =
      totalPaid >= totalCost - 0.01 // Tolerance
        ? "paid"
        : totalPaid > 0
        ? "partial"
        : "pending";

    await prisma.repair.update({
      where: { id: parseInt(id) },
      data: { paymentStatus },
    });

    res
      .status(201)
      .json({ data: payment, message: "Payment added successfully" });
  }

  async create(req: AuthRequest, res: Response) {
    const {
      customerId,
      deviceBrand,
      deviceModel,
      deviceImei,
      password,
      problemDescription,
      diagnosisNotes,
      repairNotes,
      priority,
      estimatedCost,
      finalCost,
      serviceCharge,
      estimatedCompletion,
      actualCompletion,
      warrantyProvided,
      warrantyDays,
      issues,
      extraInfo,
      items,
    } = req.body;
    console.log(req.body);
    if (!customerId || !deviceBrand || !deviceModel || !problemDescription) {
      console.log({
        customerId,
        deviceBrand,
        deviceModel,
        problemDescription,
      });
      throw new AppError(
        400,
        "Customer, device brand, model, and problem description are required"
      );
    }

    // Generate repair number
    const count = await prisma.repair.count();
    const repairNumber = `CASE-${String(count + 1).padStart(4, "0")}`;

    // Get default "Received" state
    const receivedState = await prisma.repairState.findFirst({
      where: { name: "Received" },
    });

    if (!receivedState) {
      throw new AppError(500, "Default repair state not found");
    }

    const repair = await prisma.repair.create({
      data: {
        repairNumber,
        customerId,
        deviceBrand,
        deviceModel,
        deviceImei,
        password,
        problemDescription,
        diagnosisNotes,
        repairNotes,
        priority: priority || "normal",
        estimatedCost,
        finalCost,
        serviceCharge,
        estimatedCompletion: estimatedCompletion
          ? new Date(estimatedCompletion)
          : null,
        actualCompletion: actualCompletion ? new Date(actualCompletion) : null,
        warrantyProvided: warrantyProvided || false,
        warrantyDays,
        stateId: receivedState.id,
        extraInfo,
        issues: {
          create:
            issues?.map((issue: any) => ({
              issueTypeId: issue.issueTypeId,
              description: issue.description,
            })) || [],
        },
        items: {
          create:
            items?.map((item: any) => ({
              itemName: item.item_name || item.itemName,
              description: item.description,
              quantity: item.quantity,
              unitPrice: item.unit_price || item.unitPrice,
              totalPrice: item.total_price || item.totalPrice,
              isLabor: item.is_labor || item.isLabor || false,
            })) || [],
        },
      },
      include: {
        customer: true,
        state: true,
        issues: {
          include: {
            issueType: true,
          },
        },
        items: true,
        statusHistory: true,
      },
    });

    res
      .status(201)
      .json({ data: repair, message: "Repair created successfully" });
  }

  async update(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const {
      deviceBrand,
      deviceModel,
      deviceImei,
      password,
      estimatedCost,
      finalCost,
      extraInfo,
      issues,
      serviceCharge,
    } = req.body;

    const repair = await prisma.repair.findUnique({
      where: { id: parseInt(id) },
    });

    if (!repair) {
      throw new AppError(404, "Repair not found");
    }

    const updateData: any = {
      deviceBrand,
      deviceModel,
      deviceImei,
      password,
      estimatedCost,
      finalCost,
      serviceCharge,
      extraInfo,
    };

    if (issues) {
      updateData.issues = {
        deleteMany: {},
        create: issues.map((issue: any) => ({
          issueTypeId: issue.issueTypeId,
          description: issue.description,
        })),
      };
    }

    const updated = await prisma.repair.update({
      where: { id: parseInt(id) },
      data: updateData,
      include: {
        customer: true,
        state: true,
        issues: {
          include: {
            issueType: true,
          },
        },
      },
    });

    res.json({ data: updated, message: "Repair updated successfully" });
  }

  async delete(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const repair = await prisma.repair.findUnique({
      where: { id: parseInt(id) },
    });

    if (!repair) {
      throw new AppError(404, "Repair not found");
    }

    await prisma.repair.delete({
      where: { id: parseInt(id) },
    });

    res.json({ message: "Repair deleted successfully" });
  }

  async updateState(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { stateId } = req.body;

    if (!stateId) {
      throw new AppError(400, "State ID is required");
    }

    const repair = await prisma.repair.findUnique({
      where: { id: parseInt(id) },
    });

    if (!repair) {
      throw new AppError(404, "Repair not found");
    }

    const state = await prisma.repairState.findUnique({
      where: { id: stateId },
    });

    if (!state) {
      throw new AppError(404, "Repair state not found");
    }

    // Set completion date if moving to "Delivered" state
    const completedDate =
      state.name === "Delivered" ? new Date() : repair.completedDate;

    const updated = await prisma.repair.update({
      where: { id: parseInt(id) },
      data: {
        stateId,
        completedDate,
      },
      include: {
        customer: true,
        state: true,
        issues: {
          include: {
            issueType: true,
          },
        },
      },
    });

    // Log status change in history
    try {
      await prisma.repairStatusHistory.create({
        data: {
          repairId: repair.id,
          status: state.name,
          notes: null,
          updatedBy: req.user?.username ?? null,
        },
      });
    } catch (e) {
      console.warn("Failed to create repair status history record", e);
    }

    res.json({ data: updated, message: "Repair state updated successfully" });
  }

  // Update repair status by name (status string)
  async updateStatus(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { status, notes } = req.body;

    if (!status) {
      throw new AppError(400, "Status is required");
    }

    const repair = await prisma.repair.findUnique({
      where: { id: parseInt(id) },
    });

    if (!repair) {
      throw new AppError(404, "Repair not found");
    }

    // Find state by name, case-insensitive
    const allStates = await prisma.repairState.findMany();
    const state = allStates.find(
      (s) => s.name.toLowerCase() === status.toLowerCase()
    );

    if (!state) {
      throw new AppError(404, "Repair state not found");
    }

    // Set completion date if moving to "Delivered" state
    const completedDate =
      state.name === "Delivered" ? new Date() : repair.completedDate;

    // Update the repair state
    const updated = await prisma.repair.update({
      where: { id: parseInt(id) },
      data: {
        stateId: state.id,
        completedDate,
      },
      include: {
        customer: true,
        state: true,
        issues: {
          include: {
            issueType: true,
          },
        },
        items: true, // Include items to process return to stock
      },
    });

    // If status is Cancelled, return items to stock
    if (state.name.toLowerCase() === "cancelled") {
      for (const repairItem of updated.items) {
        // Restore batches
        const batches = await prisma.repairItemBatch.findMany({
          where: { repairItemId: repairItem.id },
        });

        for (const batchRecord of batches) {
          await prisma.batch.update({
            where: { id: batchRecord.batchId },
            data: { soldQuantity: { decrement: batchRecord.quantity } },
          });
        }

        // Restore serials
        await prisma.serial.updateMany({
          where: { repairItemId: repairItem.id },
          data: { status: "available", repairItemId: null },
        });

        // Restore item stock
        // We need to find the item associated with the batch to restore stock
        for (const batchRecord of batches) {
          const batch = await prisma.batch.findUnique({
            where: { id: batchRecord.batchId },
          });
          if (batch && batch.itemId) {
            await prisma.item.update({
              where: { id: batch.itemId },
              data: { stockQuantity: { increment: batchRecord.quantity } },
            });
          }
        }

        // Clear RepairItemBatch records
        await prisma.repairItemBatch.deleteMany({
          where: { repairItemId: repairItem.id },
        });
      }
    }

    // Log status change in history
    try {
      await prisma.repairStatusHistory.create({
        data: {
          repairId: repair.id,
          status: state.name,
          notes: notes ?? null,
          updatedBy: req.user?.username ?? null,
        },
      });
    } catch (e) {
      // Ignore history logging errors; do not fail the main update
      console.warn("Failed to create repair status history record", e);
    }

    res.json({ data: updated, message: "Repair status updated successfully" });
  }

  async addItem(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const {
      itemId,
      item_name,
      itemName,
      description,
      quantity,
      unit_price,
      unitPrice,
      total_price,
      totalPrice,
      is_labor,
      isLabor,
    } = req.body;

    const repair = await prisma.repair.findUnique({
      where: { id: parseInt(id) },
    });

    if (!repair) {
      throw new AppError(404, "Repair not found");
    }

    if (itemId) {
      // Handle stock item
      const stockItem = await prisma.item.findUnique({
        where: { id: parseInt(itemId) },
        include: { serials: { include: { batch: true } } },
      });

      if (!stockItem) {
        throw new AppError(404, "Stock item not found");
      }

      const qty = parseFloat(quantity);

      if (stockItem.stockQuantity < qty) {
        throw new AppError(400, "Insufficient stock");
      }

      // Use provided unit price or default to selling price
      const price =
        unit_price !== undefined
          ? parseFloat(unit_price)
          : unitPrice !== undefined
          ? parseFloat(unitPrice)
          : stockItem.sellingPrice;
      const total =
        total_price !== undefined
          ? parseFloat(total_price)
          : totalPrice !== undefined
          ? parseFloat(totalPrice)
          : price * qty;

      const result = await prisma.$transaction(async (tx) => {
        // Create RepairItem
        const repairItem = await tx.repairItem.create({
          data: {
            repairId: parseInt(id),
            itemName: stockItem.name,
            description: description || stockItem.description,
            quantity: qty,
            unitPrice: price,
            totalPrice: total,
            isLabor: false,
          },
        });

        // Batch Tracking Logic
        let remainingQuantity = qty;
        let itemCogs = 0;

        // Sort serials by batch purchase date (FIFO)
        const availableSerials = stockItem.serials
          .filter((s) => s.status === "available")
          .sort(
            (a, b) =>
              a.batch.purchaseDate.getTime() - b.batch.purchaseDate.getTime()
          );

        for (const serial of availableSerials) {
          if (remainingQuantity <= 0) break;

          // Mark serial as sold/used
          await tx.serial.update({
            where: { id: serial.id },
            data: {
              status: "sold",
              repairItemId: repairItem.id,
            },
          });

          // Update batch sold quantity
          await tx.batch.update({
            where: { id: serial.batchId },
            data: { soldQuantity: { increment: 1 } },
          });

          // Create RepairItemBatch
          await tx.repairItemBatch.create({
            data: {
              repairItemId: repairItem.id,
              batchId: serial.batchId,
              quantity: 1,
            },
          });

          itemCogs += serial.batch.unitCost;
          remainingQuantity--;
        }

        if (remainingQuantity > 0) {
          // Find batches with available quantity (FIFO)
          const batches = await tx.batch.findMany({
            where: {
              itemId: stockItem.id,
              soldQuantity: { lt: tx.batch.fields.totalQuantity },
            },
            orderBy: { purchaseDate: "asc" },
          });

          for (const batch of batches) {
            if (remainingQuantity <= 0) break;

            const availableInBatch = batch.totalQuantity - batch.soldQuantity;
            const takeFromBatch = Math.min(remainingQuantity, availableInBatch);

            await tx.batch.update({
              where: { id: batch.id },
              data: { soldQuantity: { increment: takeFromBatch } },
            });

            await tx.repairItemBatch.create({
              data: {
                repairItemId: repairItem.id,
                batchId: batch.id,
                quantity: takeFromBatch,
              },
            });

            itemCogs += batch.unitCost * takeFromBatch;
            remainingQuantity -= takeFromBatch;
          }
        }

        // Update Stock
        await tx.item.update({
          where: { id: stockItem.id },
          data: { stockQuantity: { decrement: qty } },
        });

        // Create StockUsage
        await tx.stockUsage.create({
          data: {
            itemId: stockItem.id,
            repairId: parseInt(id),
            quantity: qty,
            unitCost: itemCogs / qty,
            reason: `Used in repair #${repair.repairNumber}`,
          },
        });

        return repairItem;
      });

      res
        .status(201)
        .json({ data: result, message: "Stock item added to repair" });
      return;
    }

    const item = await prisma.repairItem.create({
      data: {
        repairId: parseInt(id),
        itemName: item_name || itemName,
        description,
        quantity: parseFloat(quantity),
        unitPrice: parseFloat(unit_price || unitPrice),
        totalPrice: parseFloat(total_price || totalPrice),
        isLabor: is_labor || isLabor || false,
      },
    });

    res
      .status(201)
      .json({ data: item, message: "Repair item added successfully" });
  }

  async updateItem(req: AuthRequest, res: Response) {
    const { id, itemId } = req.params;
    const {
      item_name,
      itemName,
      description,
      quantity,
      unit_price,
      unitPrice,
      total_price,
      totalPrice,
      is_labor,
      isLabor,
    } = req.body;

    const repair = await prisma.repair.findUnique({
      where: { id: parseInt(id) },
    });

    if (!repair) {
      throw new AppError(404, "Repair not found");
    }

    const data: any = {};
    if (item_name || itemName) data.itemName = item_name || itemName;
    if (description !== undefined) data.description = description;
    if (quantity !== undefined) data.quantity = parseFloat(quantity);
    if (unit_price !== undefined || unitPrice !== undefined)
      data.unitPrice = parseFloat(unit_price || unitPrice);
    if (total_price !== undefined || totalPrice !== undefined)
      data.totalPrice = parseFloat(total_price || totalPrice);
    if (is_labor !== undefined || isLabor !== undefined)
      data.isLabor = is_labor || isLabor;

    const updated = await prisma.repairItem.update({
      where: { id: parseInt(itemId) },
      data,
    });

    res.json({ data: updated, message: "Repair item updated successfully" });
  }

  async deleteItem(req: AuthRequest, res: Response) {
    const { itemId } = req.params;

    // Return to stock logic
    const repairItem = await prisma.repairItem.findUnique({
      where: { id: parseInt(itemId) },
      // include: { batches: true }, // Removed invalid relation
    });

    if (repairItem) {
      // Restore batches
      const batches = await prisma.repairItemBatch.findMany({
        where: { repairItemId: parseInt(itemId) },
      });

      for (const batchRecord of batches) {
        await prisma.batch.update({
          where: { id: batchRecord.batchId },
          data: { soldQuantity: { decrement: batchRecord.quantity } },
        });
      }

      // Restore serials
      await prisma.serial.updateMany({
        where: { repairItemId: parseInt(itemId) },
        data: { status: "available", repairItemId: null },
      });

      // Restore item stock if it was a stock item (we need to know if it was linked to an item, currently RepairItem doesn't strictly enforce itemId link but we added it in create)
      // We need to check if we added `itemId` to RepairItem model.
      // Wait, I didn't add `itemId` to `RepairItem` in schema.prisma in the plan.
      // But `StockUsage` has `itemId`.
      // Let's check if `RepairItem` has `itemId`.
      // Looking at schema.prisma earlier: `RepairItem` does NOT have `itemId`.
      // So we can't easily know which Item to restore unless we infer from name or check StockUsage.
      // However, `RepairItemBatch` links to `Batch`, and `Batch` links to `Item`.
      // So we can restore stock based on batches!

      for (const batchRecord of batches) {
        const batch = await prisma.batch.findUnique({
          where: { id: batchRecord.batchId },
        });
        if (batch && batch.itemId) {
          await prisma.item.update({
            where: { id: batch.itemId },
            data: { stockQuantity: { increment: batchRecord.quantity } },
          });
        }
      }
    }

    await prisma.repairItem.delete({
      where: { id: parseInt(itemId) },
    });

    res.json({ message: "Repair item deleted successfully" });
  }

  async updateServiceCharge(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { serviceCharge } = req.body;

    if (serviceCharge === undefined || serviceCharge === null) {
      throw new AppError(400, "Service charge is required");
    }

    const repair = await prisma.repair.findUnique({
      where: { id: parseInt(id) },
    });

    if (!repair) {
      throw new AppError(404, "Repair not found");
    }

    const updated = await prisma.repair.update({
      where: { id: parseInt(id) },
      include: {
        customer: true,
        state: true,
        issues: {
          include: {
            issueType: true,
          },
        },
      },
      data: {
        serviceCharge: parseFloat(serviceCharge),
      },
    });

    res.json({ data: updated, message: "Service charge updated successfully" });
  }
}
