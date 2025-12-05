import { Router } from "express";
import { PaymentController } from "../controllers/payment.controller";
import { authenticate } from "../middleware/auth";

const router: Router = Router();
const controller = new PaymentController();

router.use(authenticate);

router.post("/allocate", controller.allocatePayment.bind(controller));

export default router;
