import { Router } from "express";
import { ItemController } from "../controllers/item.controller";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/errorHandler";

const router = Router();
const itemController = new ItemController();

router.get(
  "/",
  authenticate,
  asyncHandler(itemController.getAll.bind(itemController))
);
router.get(
  "/search",
  authenticate,
  asyncHandler(itemController.search.bind(itemController))
);
router.get(
  "/low-stock",
  authenticate,
  asyncHandler(itemController.getLowStock.bind(itemController))
);
router.get(
  "/:id",
  authenticate,
  asyncHandler(itemController.getById.bind(itemController))
);
router.post(
  "/",
  authenticate,
  asyncHandler(itemController.create.bind(itemController))
);
router.put(
  "/:id",
  authenticate,
  asyncHandler(itemController.update.bind(itemController))
);
router.delete(
  "/:id",
  authenticate,
  asyncHandler(itemController.delete.bind(itemController))
);
router.put(
  "/:id/stock",
  authenticate,
  asyncHandler(itemController.adjustStock.bind(itemController))
);

export default router;
