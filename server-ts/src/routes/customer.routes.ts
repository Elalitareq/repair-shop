import { Router } from "express";
import { CustomerController } from "../controllers/customer.controller";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/errorHandler";

const router = Router();
const customerController = new CustomerController();

router.get(
  "/",
  authenticate,
  asyncHandler(customerController.getAll.bind(customerController))
);
router.get(
  "/search",
  authenticate,
  asyncHandler(customerController.search.bind(customerController))
);
router.get(
  "/:id",
  authenticate,
  asyncHandler(customerController.getById.bind(customerController))
);
router.post(
  "/",
  authenticate,
  asyncHandler(customerController.create.bind(customerController))
);
router.put(
  "/:id",
  authenticate,
  asyncHandler(customerController.update.bind(customerController))
);
router.delete(
  "/:id",
  authenticate,
  asyncHandler(customerController.delete.bind(customerController))
);

export default router;
