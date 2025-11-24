import { Response } from "express";
import { AuthRequest } from "../middleware/auth";
import { prisma } from "../utils/prisma";
import { validationResult } from "express-validator";

export class ReferenceController {
  async getConditions(_req: AuthRequest, res: Response) {
    const conditions = await prisma.condition.findMany({
      orderBy: { name: "asc" },
    });
    res.json({ data: conditions });
  }

  async createCondition(req: AuthRequest, res: Response) {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      res.status(400).json({ errors: errors.array() });
      return;
    }

    const { name, description } = req.body;
    const condition = await prisma.condition.create({
      data: { name, description },
    });
    res.status(201).json({ data: condition });
  }

  async updateCondition(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { name, description } = req.body;

    const condition = await prisma.condition.update({
      where: { id: parseInt(id) },
      data: { name, description },
    });
    res.json({ data: condition });
  }

  async deleteCondition(req: AuthRequest, res: Response) {
    const { id } = req.params;
    await prisma.condition.delete({
      where: { id: parseInt(id) },
    });
    res.json({ message: "Condition deleted successfully" });
  }

  async getQualities(_req: AuthRequest, res: Response) {
    const qualities = await prisma.quality.findMany({
      orderBy: { name: "asc" },
    });
    res.json({ data: qualities });
  }

  async createQuality(req: AuthRequest, res: Response) {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      res.status(400).json({ errors: errors.array() });
      return;
    }

    const { name, description } = req.body;
    const quality = await prisma.quality.create({
      data: { name, description },
    });
    res.status(201).json({ data: quality });
  }

  async updateQuality(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { name, description } = req.body;

    const quality = await prisma.quality.update({
      where: { id: parseInt(id) },
      data: { name, description },
    });
    res.json({ data: quality });
  }

  async deleteQuality(req: AuthRequest, res: Response) {
    const { id } = req.params;
    await prisma.quality.delete({
      where: { id: parseInt(id) },
    });
    res.json({ message: "Quality deleted successfully" });
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
