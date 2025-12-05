import { Response } from "express";
import { AppError } from "../middleware/errorHandler";
import { AuthRequest } from "../middleware/auth";
import { prisma } from "../utils/prisma";

export class PaymentController {
  async allocatePayment(req: AuthRequest, res: Response) {
    const {
      customerId,
      paymentMethodId,
      amount,
      referenceNumber,
      notes,
      allocations,
    } = req.body;

    if (!customerId || !paymentMethodId || !amount) {
      throw new AppError(
        400,
        "Customer, payment method, and amount are required"
      );
    }

    // Validate allocations sum matches total amount if allocations are provided
    if (allocations && allocations.length > 0) {
      const totalAllocated = allocations.reduce(
        (sum: number, a: any) => sum + a.amount,
        0
      );
      if (Math.abs(totalAllocated - amount) > 0.01) {
        throw new AppError(
          400,
          "Sum of allocations must match total payment amount"
        );
      }
    }

    const result = await prisma.$transaction(async (tx) => {
      // 1. Create the main Payment record
      const payment = await tx.payment.create({
        data: {
          customerId,
          paymentMethodId,
          amount,
          referenceNumber,
          notes,
          status: "completed",
        },
        include: {
          paymentMethod: true,
        },
      });

      // 2. Process allocations
      if (allocations && allocations.length > 0) {
        for (const allocation of allocations) {
          // Create allocation record
          await tx.paymentAllocation.create({
            data: {
              paymentId: payment.id,
              saleId: allocation.saleId,
              repairId: allocation.repairId,
              amount: allocation.amount,
            },
          });

          // Update Sale status if applicable
          if (allocation.saleId) {
            const sale = await tx.sale.findUnique({
              where: { id: allocation.saleId },
            });
            if (sale) {
              // Calculate total paid for this sale including this new allocation
              // We need to sum up direct payments AND allocations
              const directPayments = await tx.payment.aggregate({
                where: { saleId: sale.id },
                _sum: { amount: true },
              });

              const allocatedPayments = await tx.paymentAllocation.aggregate({
                where: { saleId: sale.id },
                _sum: { amount: true },
              });

              const totalPaid =
                (directPayments._sum.amount || 0) +
                (allocatedPayments._sum.amount || 0);

              let paymentStatus = "pending";
              if (totalPaid >= sale.totalAmount - 0.01) {
                paymentStatus = "paid";
              } else if (totalPaid > 0) {
                paymentStatus = "partial";
              }

              await tx.sale.update({
                where: { id: sale.id },
                data: { paymentStatus },
              });
            }
          }

          // Update Repair status if applicable
          if (allocation.repairId) {
            const repair = await tx.repair.findUnique({
              where: { id: allocation.repairId },
              include: { items: true },
            });

            if (repair) {
              const itemsCost = repair.items.reduce(
                (sum, item) => sum + item.totalPrice,
                0
              );
              const totalCost = (repair.serviceCharge || 0) + itemsCost;

              const directPayments = await tx.payment.aggregate({
                where: { repairId: repair.id },
                _sum: { amount: true },
              });

              const allocatedPayments = await tx.paymentAllocation.aggregate({
                where: { repairId: repair.id },
                _sum: { amount: true },
              });

              const totalPaid =
                (directPayments._sum.amount || 0) +
                (allocatedPayments._sum.amount || 0);

              let paymentStatus = "pending";
              if (totalPaid >= totalCost - 0.01) {
                paymentStatus = "paid";
              } else if (totalPaid > 0) {
                paymentStatus = "partial";
              }

              await tx.repair.update({
                where: { id: repair.id },
                data: { paymentStatus },
              });
            }
          }
        }
      }

      return payment;
    });

    res
      .status(201)
      .json({ data: result, message: "Payment allocated successfully" });
  }
}
