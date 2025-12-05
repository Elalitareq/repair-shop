import { Router } from "express";
import { SaleController } from "../controllers/sale.controller";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/errorHandler";

const router: Router = Router();
const saleController = new SaleController();

router.get(
  "/",
  authenticate,
  asyncHandler(saleController.getAll.bind(saleController))
);
router.get(
  "/reports/daily",
  authenticate,
  asyncHandler(saleController.getDailyReport.bind(saleController))
);
router.get(
  "/reports/monthly",
  authenticate,
  asyncHandler(saleController.getMonthlyReport.bind(saleController))
);
router.get(
  "/:id",
  authenticate,
  asyncHandler(saleController.getById.bind(saleController))
);
router.post(
  "/",
  authenticate,
  asyncHandler(saleController.create.bind(saleController))
);
router.put(
  "/:id",
  authenticate,
  asyncHandler(saleController.update.bind(saleController))
);
router.delete(
  "/:id",
  authenticate,
  asyncHandler(saleController.delete.bind(saleController))
);
router.put(
  "/:id/status",
  authenticate,
  asyncHandler(saleController.updateStatus.bind(saleController))
);

router.post(
  "/:id/payments",
  authenticate,
  asyncHandler(saleController.createPayment.bind(saleController))
);

export default router;
