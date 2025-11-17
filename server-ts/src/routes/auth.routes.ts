import { Router } from "express";
import { body } from "express-validator";
import { AuthController } from "../controllers/auth.controller";
import { asyncHandler } from "../middleware/errorHandler";

const router = Router();
const authController = new AuthController();

router.post(
  "/login",
  [
    body("username").notEmpty().withMessage("Username is required"),
    body("password").notEmpty().withMessage("Password is required"),
  ],
  asyncHandler(authController.login.bind(authController))
);

router.post(
  "/register",
  [
    body("username").notEmpty().withMessage("Username is required"),
    body("email").isEmail().withMessage("Valid email is required"),
    body("password")
      .isLength({ min: 6 })
      .withMessage("Password must be at least 6 characters"),
  ],
  asyncHandler(authController.register.bind(authController))
);

router.post(
  "/refresh",
  asyncHandler(authController.refresh.bind(authController))
);

export default router;
