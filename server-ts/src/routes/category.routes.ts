import { Router } from "express";
import { body } from "express-validator";
import { CategoryController } from "../controllers/category.controller";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/errorHandler";

const router = Router();
const categoryController = new CategoryController();

router.get(
  "/",
  authenticate,
  asyncHandler(categoryController.getAll.bind(categoryController))
);
router.get(
  "/:id",
  authenticate,
  asyncHandler(categoryController.getById.bind(categoryController))
);
router.post(
  "/",
  authenticate,
  [body("name").notEmpty().withMessage("Name is required")],
  asyncHandler(categoryController.create.bind(categoryController))
);
router.put(
  "/:id",
  authenticate,
  asyncHandler(categoryController.update.bind(categoryController))
);
router.delete(
  "/:id",
  authenticate,
  asyncHandler(categoryController.delete.bind(categoryController))
);

export default router;
