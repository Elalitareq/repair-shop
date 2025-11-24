import { Response } from "express";
import { AppError } from "../middleware/errorHandler";
import { AuthRequest } from "../middleware/auth";
import { prisma } from "../utils/prisma";

export class SerialController {
  async getAll(req: AuthRequest, res: Response) {
    const { itemId, batchId } = req.query;

    const where: any = {};
    if (itemId) where.itemId = parseInt(itemId as string);
    if (batchId) where.batchId = parseInt(batchId as string);

    // @ts-ignore - generated Prisma client will include `serial` after prisma generate
    const serials = await prisma.serial.findMany({
      where,
      include: { item: true, batch: true },
      orderBy: { createdAt: "desc" },
    });

    res.json({ data: serials });
  }

  async create(req: AuthRequest, res: Response) {
    const { imei, itemId, batchId } = req.body;
    if (!imei || !itemId || !batchId) {
      throw new AppError(400, "imei, itemId, and batchId are required");
    }

    // Check unique imei
    // @ts-ignore - generated Prisma client will include `serial` after prisma generate
    const existing = await prisma.serial.findUnique({ where: { imei } });
    if (existing) throw new AppError(409, "IMEI already exists");

    // @ts-ignore - generated Prisma client will include `serial` after prisma generate
    const created = await prisma.serial.create({
      data: {
        imei,
        itemId,
        batchId,
      },
      include: { item: true, batch: true },
    });

    res.status(201).json({ data: created, message: "Serial created" });
  }

  async update(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { imei, itemId, batchId } = req.body;

    // @ts-ignore - generated Prisma client will include `serial` after prisma generate
    const existing = await prisma.serial.findUnique({
      where: { id: parseInt(id) },
    });
    if (!existing) throw new AppError(404, "Serial not found");

    // Check unique imei if changing
    if (imei && imei !== existing.imei) {
      // @ts-ignore - generated Prisma client will include `serial` after prisma generate
      const duplicate = await prisma.serial.findUnique({ where: { imei } });
      if (duplicate) throw new AppError(409, "IMEI already exists");
    }

    // @ts-ignore - generated Prisma client will include `serial` after prisma generate
    const updated = await prisma.serial.update({
      where: { id: parseInt(id) },
      data: {
        ...(imei !== undefined && { imei }),
        ...(itemId !== undefined && { itemId }),
        ...(batchId !== undefined && { batchId }),
      },
      include: { item: true, batch: true },
    });

    res.json({ data: updated, message: "Serial updated" });
  }

  async delete(req: AuthRequest, res: Response) {
    const { id } = req.params;

    // @ts-ignore - generated Prisma client will include `serial` after prisma generate
    const serial = await prisma.serial.findUnique({
      where: { id: parseInt(id) },
    });
    if (!serial) throw new AppError(404, "Serial not found");

    // @ts-ignore - generated Prisma client will include `serial` after prisma generate
    await prisma.serial.delete({ where: { id: parseInt(id) } });

    res.json({ message: "Serial deleted" });
  }
}
