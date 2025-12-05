import { Router } from "express";
import { RepairController } from "../controllers/repair.controller";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/errorHandler";

const router: Router = Router();
const repairController = new RepairController();

router.get("/", authenticate, asyncHandler(repairController.getAll));
router.get("/:id", authenticate, asyncHandler(repairController.getById));
router.post("/", authenticate, asyncHandler(repairController.create));
router.put("/:id", authenticate, asyncHandler(repairController.update));
router.delete("/:id", authenticate, asyncHandler(repairController.delete));
router.put(
  "/:id/state",
  authenticate,
  asyncHandler(repairController.updateState)
);
router.put(
  "/:id/status",
  authenticate,
  asyncHandler(repairController.updateStatus)
);

router.post(
  "/:id/items",
  authenticate,
  asyncHandler(repairController.addItem)
);
router.post(
  "/:id/payments",
  authenticate,
  asyncHandler(repairController.createPayment)
);
router.put(
  "/:id/items/:itemId",
  authenticate,
  asyncHandler(repairController.updateItem)
);
router.delete(
  "/:id/items/:itemId",
  authenticate,
  asyncHandler(repairController.deleteItem)
);
router.patch(
  "/:id/service-charge",
  authenticate,
  asyncHandler(repairController.updateServiceCharge.bind(repairController))
);

export default router;
