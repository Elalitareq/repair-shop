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

export default router;
