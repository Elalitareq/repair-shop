import { Router } from "express";
import { BarcodeController } from "../controllers/barcode.controller";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/errorHandler";

const router: Router = Router();
const barcodeController = new BarcodeController();

// Generate barcode for item
router.get(
  "/item/:id",
  authenticate,
  asyncHandler(barcodeController.generateForItem.bind(barcodeController))
);

// Generate barcode for serial
router.get(
  "/serial/:id",
  authenticate,
  asyncHandler(barcodeController.generateForSerial.bind(barcodeController))
);

// Scan barcode for lookup
router.post(
  "/scan",
  authenticate,
  asyncHandler(barcodeController.scan.bind(barcodeController))
);

export default router;
