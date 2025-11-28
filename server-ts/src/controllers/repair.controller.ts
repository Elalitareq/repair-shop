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
        items: true,
        statusHistory: true,
        stockUsages: {
          include: {
            item: true,
          },
        },
      },
    });

    if (!repair) {
      throw new AppError(404, "Repair not found");
    }

    res.json({ data: repair });
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
      estimatedCompletion,
      actualCompletion,
      warrantyProvided,
      warrantyDays,
      issues,
      extraInfo,
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
    const repairNumber = `REP-${new Date().getFullYear()}-${String(
      count + 1
    ).padStart(4, "0")}`;

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
    } = req.body;

    const repair = await prisma.repair.findUnique({
      where: { id: parseInt(id) },
    });

    if (!repair) {
      throw new AppError(404, "Repair not found");
    }

    const updated = await prisma.repair.update({
      where: { id: parseInt(id) },
      data: {
        deviceBrand,
        deviceModel,
        deviceImei,
        password,
        estimatedCost,
        finalCost,
        extraInfo,
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

    res.json({ data: updated, message: "Repair state updated successfully" });
  }
}
