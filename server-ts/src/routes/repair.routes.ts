import { Router } from "express";
import { RepairController } from "../controllers/repair.controller";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/errorHandler";

const router: Router = Router();
const repairController = new RepairController();

router.get(
  "/",
  authenticate,
  asyncHandler(repairController.getAll.bind(repairController))
);
router.get(
  "/:id",
  authenticate,
  asyncHandler(repairController.getById.bind(repairController))
);
router.post(
  "/",
  authenticate,
  asyncHandler(repairController.create.bind(repairController))
);
router.put(
  "/:id",
  authenticate,
  asyncHandler(repairController.update.bind(repairController))
);
router.delete(
  "/:id",
  authenticate,
  asyncHandler(repairController.delete.bind(repairController))
);
router.put(
  "/:id/state",
  authenticate,
  asyncHandler(repairController.updateState.bind(repairController))
);

export default router;
