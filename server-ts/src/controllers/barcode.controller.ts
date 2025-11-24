import { Response } from "express";
import bwipjs from "bwip-js";
import { AppError } from "../middleware/errorHandler";
import { AuthRequest } from "../middleware/auth";
import { prisma } from "../utils/prisma";

export class BarcodeController {
  async generateForItem(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const item = await prisma.item.findUnique({
      where: { id: parseInt(id) },
      include: { serials: true },
    });

    if (!item) {
      throw new AppError(404, "Item not found");
    }

    // Use item ID as barcode data, or first serial IMEI if available
    const barcodeData =
      item.serials.length > 0 ? item.serials[0].imei : `ITEM-${item.id}`;

    try {
      const barcodeBuffer = await bwipjs.toBuffer({
        bcid: "code128", // Barcode type
        text: barcodeData,
        scale: 3,
        height: 10,
        includetext: true,
        textxalign: "center",
      });

      // Convert to base64 for response
      const base64 = barcodeBuffer.toString("base64");
      res.json({
        barcode: barcodeData,
        format: "png",
        data: `data:image/png;base64,${base64}`,
        item: {
          id: item.id,
          name: item.name,
        },
      });
    } catch (error) {
      throw new AppError(500, "Failed to generate barcode");
    }
  }

  async generateForSerial(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const serial = await prisma.serial.findUnique({
      where: { id: parseInt(id) },
      include: { item: true },
    });

    if (!serial) {
      throw new AppError(404, "Serial not found");
    }

    try {
      const barcodeBuffer = await bwipjs.toBuffer({
        bcid: "code128",
        text: serial.imei,
        scale: 3,
        height: 10,
        includetext: true,
        textxalign: "center",
      });

      const base64 = barcodeBuffer.toString("base64");
      res.json({
        barcode: serial.imei,
        format: "png",
        data: `data:image/png;base64,${base64}`,
        serial: {
          id: serial.id,
          imei: serial.imei,
          item: {
            id: serial.item.id,
            name: serial.item.name,
          },
        },
      });
    } catch (error) {
      throw new AppError(500, "Failed to generate barcode");
    }
  }

  async scan(req: AuthRequest, res: Response): Promise<void> {
    const { barcode } = req.body;

    if (!barcode) {
      throw new AppError(400, "Barcode data is required");
    }

    // Try to find by IMEI first
    let serial = await prisma.serial.findUnique({
      where: { imei: barcode },
      include: {
        item: {
          include: {
            category: true,
            condition: true,
            quality: true,
          },
        },
      },
    });

    if (serial) {
      res.json({
        type: "serial",
        data: {
          serial: {
            id: serial.id,
            imei: serial.imei,
          },
          item: {
            id: serial.item.id,
            name: serial.item.name,
            category: serial.item.category,
            condition: serial.item.condition,
            quality: serial.item.quality,
            stock_quantity: serial.item.stockQuantity,
            selling_price: serial.item.sellingPrice,
          },
        },
      });
      return;
    }

    // Try to find by item ID format (ITEM-{id})
    const itemMatch = barcode.match(/^ITEM-(\d+)$/);
    if (itemMatch) {
      const itemId = parseInt(itemMatch[1]);
      const item = await prisma.item.findUnique({
        where: { id: itemId },
        include: {
          category: true,
          condition: true,
          quality: true,
          serials: true,
        },
      });

      if (item) {
        res.json({
          type: "item",
          data: {
            item: {
              id: item.id,
              name: item.name,
              category: item.category,
              condition: item.condition,
              quality: item.quality,
              stock_quantity: item.stockQuantity,
              selling_price: item.sellingPrice,
              serials: item.serials.map((s) => ({ id: s.id, imei: s.imei })),
            },
          },
        });
        return;
      }
    }

    // Barcode not found
    res.json({
      type: "unknown",
      message: "Barcode not recognized",
      barcode,
    });
  }
}
