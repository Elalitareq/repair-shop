import { Router } from "express";
import backupController from "../controllers/backup.controller";
import { authenticate, requireRole } from "../middleware/auth";
import { asyncHandler } from "../middleware/errorHandler";

const router: Router = Router();

// Download the current sqlite database file
router.get(
  "/download",
  authenticate,
  requireRole(["admin"]),
  asyncHandler(backupController.download.bind(backupController))
);

// Restore the database by uploading a sqlite file
// multer middleware is used inside controller uploadMiddleware
router.post(
  "/restore",
  authenticate,
  requireRole(["admin"]),
  backupController.uploadMiddleware(),
  asyncHandler(backupController.restore.bind(backupController))
);

export default router;
