import { Router } from "express";
import { ReferenceController } from "../controllers/reference.controller";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/errorHandler";

const router = Router();
const referenceController = new ReferenceController();

router.get(
  "/conditions",
  authenticate,
  asyncHandler(referenceController.getConditions.bind(referenceController))
);
router.get(
  "/qualities",
  authenticate,
  asyncHandler(referenceController.getQualities.bind(referenceController))
);
router.get(
  "/issue-types",
  authenticate,
  asyncHandler(referenceController.getIssueTypes.bind(referenceController))
);
router.get(
  "/repair-states",
  authenticate,
  asyncHandler(referenceController.getRepairStates.bind(referenceController))
);
router.get(
  "/payment-methods",
  authenticate,
  asyncHandler(referenceController.getPaymentMethods.bind(referenceController))
);

export default router;
