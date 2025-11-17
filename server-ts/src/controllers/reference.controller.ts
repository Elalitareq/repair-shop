import { Response } from "express";
import { AuthRequest } from "../middleware/auth";
import { prisma } from "../utils/prisma";

export class ReferenceController {
  async getConditions(_req: AuthRequest, res: Response) {
    const conditions = await prisma.condition.findMany({
      orderBy: { name: "asc" },
    });
    res.json({ data: conditions });
  }

  async getQualities(_req: AuthRequest, res: Response) {
    const qualities = await prisma.quality.findMany({
      orderBy: { name: "asc" },
    });
    res.json({ data: qualities });
  }

  async getIssueTypes(_req: AuthRequest, res: Response) {
    const issueTypes = await prisma.issueType.findMany({
      orderBy: { name: "asc" },
    });
    res.json({ data: issueTypes });
  }

  async getRepairStates(_req: AuthRequest, res: Response) {
    const repairStates = await prisma.repairState.findMany({
      orderBy: { order: "asc" },
    });
    res.json({ data: repairStates });
  }

  async getPaymentMethods(_req: AuthRequest, res: Response) {
    const paymentMethods = await prisma.paymentMethod.findMany({
      orderBy: { name: "asc" },
    });
    res.json({ data: paymentMethods });
  }
}
