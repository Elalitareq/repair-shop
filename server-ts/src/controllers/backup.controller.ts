import fs from "fs";
import path from "path";
import multer from "multer";
import { RequestHandler, Response } from "express";
import { prisma } from "../utils/prisma";
import { AppError } from "../middleware/errorHandler";
import { AuthRequest } from "../middleware/auth";

const upload = multer({ dest: "uploads/" });

function getSqliteDbPath() {
  let dbUrl = process.env.DATABASE_URL || "file:./database/repair_shop.db";

  // Strip surrounding quotes if present (dotenv may keep them)
  dbUrl = dbUrl.replace(/^\"(.*)\"$/s, "$1").replace(/^\'(.*)\'$/s, "$1");

  if (dbUrl.startsWith("file:")) dbUrl = dbUrl.slice(5);

  // If it's already absolute, check it directly; otherwise build candidate paths
  const candidates: string[] = [];
  const asIs = dbUrl;
  candidates.push(asIs);

  // Relative to current working directory
  candidates.push(path.join(process.cwd(), dbUrl));

  // Common location used in this repo: prisma/database/<file>
  candidates.push(
    path.join(process.cwd(), "prisma", "database", path.basename(dbUrl))
  );

  // Also allow path relative to this source file (e.g., when running from different CWD)
  candidates.push(path.join(__dirname, "..", "..", dbUrl));
  candidates.push(
    path.join(__dirname, "..", "..", "prisma", "database", path.basename(dbUrl))
  );

  for (const p of candidates) {
    try {
      if (fs.existsSync(p)) return path.resolve(p);
    } catch (e) {
      // ignore and continue
    }
  }

  // If we didn't find an existing file, return the most reasonable absolute path
  return path.resolve(path.join(process.cwd(), dbUrl));
}

export class BackupController {
  async download(req: AuthRequest, res: Response) {
    // Only allow admin users
    if (!req.user || req.user.role !== "admin") {
      throw new AppError(403, "Insufficient permissions");
    }

    const dbPath = getSqliteDbPath();
    if (!fs.existsSync(dbPath)) {
      throw new AppError(404, `Database file not found at path: ${dbPath}`);
    }

    const fileName = `repair_shop_backup_${new Date()
      .toISOString()
      .replace(/[:.]/g, "-")}.db`;

    res.download(dbPath, fileName, (err) => {
      if (err) {
        throw new AppError(500, "Failed to download database backup");
      }
    });
  }

  // Use multer in the route, but also expose a helper to wrap it as middleware
  uploadMiddleware(): RequestHandler {
    return upload.single("file");
  }

  async restore(req: AuthRequest, res: Response) {
    if (!req.user || req.user.role !== "admin") {
      throw new AppError(403, "Insufficient permissions");
    }

    // multer puts file metadata on req.file
    const file = (req as any).file;
    if (!file) throw new AppError(400, "No file provided");

    const dbPath = getSqliteDbPath();
    const uploadedPath = file.path as string;

    if (!fs.existsSync(uploadedPath)) {
      throw new AppError(
        400,
        `Uploaded file not found on server: ${uploadedPath}`
      );
    }

    // Validate extension
    const ext = path.extname(file.originalname).toLowerCase();
    if (![".db", ".sqlite"].includes(ext)) {
      fs.unlinkSync(uploadedPath);
      throw new AppError(400, "Invalid file type. Use .db or .sqlite");
    }

    try {
      // Disconnect Prisma, replace file, reconnect
      await prisma.$disconnect();

      // Ensure destination directory exists
      const destDir = path.dirname(dbPath);
      fs.mkdirSync(destDir, { recursive: true });

      // Replace the db file
      fs.copyFileSync(uploadedPath, dbPath);
      fs.unlinkSync(uploadedPath);

      // Reconnect and validate
      await prisma.$connect();
      // Quick check
      await prisma.$queryRaw`SELECT 1`;
    } catch (err) {
      throw new AppError(500, `Failed to restore database: ${err}`);
    }

    res.json({ message: "Database restored successfully" });
  }
}

export default new BackupController();
