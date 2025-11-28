import { Router } from "express";
import { body } from "express-validator";
import { ReferenceController } from "../controllers/reference.controller";
import { authenticate } from "../middleware/auth";
import { asyncHandler } from "../middleware/errorHandler";

const router: Router = Router();
const referenceController = new ReferenceController();

// Conditions
router.get(
  "/conditions",
  authenticate,
  asyncHandler(referenceController.getConditions.bind(referenceController))
);
router.post(
  "/conditions",
  authenticate,
  [body("name").notEmpty().withMessage("Name is required")],
  asyncHandler(referenceController.createCondition.bind(referenceController))
);
router.put(
  "/conditions/:id",
  authenticate,
  asyncHandler(referenceController.updateCondition.bind(referenceController))
);
router.delete(
  "/conditions/:id",
  authenticate,
  asyncHandler(referenceController.deleteCondition.bind(referenceController))
);

// Qualities
router.get(
  "/qualities",
  authenticate,
  asyncHandler(referenceController.getQualities.bind(referenceController))
);
router.post(
  "/qualities",
  authenticate,
  [body("name").notEmpty().withMessage("Name is required")],
  asyncHandler(referenceController.createQuality.bind(referenceController))
);
router.put(
  "/qualities/:id",
  authenticate,
  asyncHandler(referenceController.updateQuality.bind(referenceController))
);
router.delete(
  "/qualities/:id",
  authenticate,
  asyncHandler(referenceController.deleteQuality.bind(referenceController))
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
router.post(
  "/payment-methods",
  authenticate,
  asyncHandler(
    referenceController.createPaymentMethod.bind(referenceController)
  )
);
router.put(
  "/payment-methods/:id",
  authenticate,
  asyncHandler(
    referenceController.updatePaymentMethod.bind(referenceController)
  )
);
router.delete(
  "/payment-methods/:id",
  authenticate,
  asyncHandler(
    referenceController.deletePaymentMethod.bind(referenceController)
  )
);

export default router;
