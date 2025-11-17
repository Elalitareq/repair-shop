import { Router } from "express";
import authRoutes from "./auth.routes";
import categoryRoutes from "./category.routes";
import customerRoutes from "./customer.routes";
import itemRoutes from "./item.routes";
import repairRoutes from "./repair.routes";
import saleRoutes from "./sale.routes";
import referenceRoutes from "./reference.routes";

const router = Router();

router.use("/auth", authRoutes);
router.use("/categories", categoryRoutes);
router.use("/customers", customerRoutes);
router.use("/items", itemRoutes);
router.use("/repairs", repairRoutes);
router.use("/sales", saleRoutes);
router.use("/reference", referenceRoutes);

export default router;
