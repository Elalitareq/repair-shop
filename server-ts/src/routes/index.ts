import { Router } from "express";
import authRoutes from "./auth.routes";
import categoryRoutes from "./category.routes";
import customerRoutes from "./customer.routes";
import itemRoutes from "./item.routes";
import repairRoutes from "./repair.routes";
import saleRoutes from "./sale.routes";
import referenceRoutes from "./reference.routes";
import batchRoutes from "./batch.routes";
import serialRoutes from "./serial.routes";
import barcodeRoutes from "./barcode.routes";
import backupRoutes from "./backup.routes";
import paymentRoutes from "./payment.routes";

const router: Router = Router();

router.use("/auth", authRoutes);
router.use("/categories", categoryRoutes);
router.use("/customers", customerRoutes);
router.use("/items", itemRoutes);
router.use("/repairs", repairRoutes);
router.use("/sales", saleRoutes);
router.use("/reference", referenceRoutes);
router.use("/batches", batchRoutes);
router.use("/serials", serialRoutes);
router.use("/barcodes", barcodeRoutes);
router.use("/backups", backupRoutes);
router.use("/payments", paymentRoutes);

export default router;
