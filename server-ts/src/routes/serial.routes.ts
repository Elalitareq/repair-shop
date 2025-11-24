import { Router } from "express";
import { SerialController } from "../controllers/serial.controller";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/errorHandler";

const router: Router = Router();
const controller = new SerialController();

router.get("/", authenticate, asyncHandler(controller.getAll.bind(controller)));
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

export default router;
