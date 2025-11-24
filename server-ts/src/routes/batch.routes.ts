import { Router } from "express";
import { BatchController } from "../controllers/batch.controller";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/errorHandler";

const router: Router = Router();
const controller = new BatchController();

router.get("/", authenticate, asyncHandler(controller.getAll.bind(controller)));
router.get(
  "/:id",
  authenticate,
  asyncHandler(controller.getById.bind(controller))
);
router.post(
  "/",
  authenticate,
  asyncHandler(controller.create.bind(controller))
);
router.put(
  "/:id",
  authenticate,
  asyncHandler(controller.update.bind(controller))
);
router.delete(
  "/:id",
  authenticate,
  asyncHandler(controller.delete.bind(controller))
);
router.get(
  "/item/:itemId",
  authenticate,
  asyncHandler(controller.getForItem.bind(controller))
);

export default router;
