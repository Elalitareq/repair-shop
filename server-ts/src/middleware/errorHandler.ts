import { Request, Response, NextFunction } from "express";
import { logger } from "../utils/logger";

export class AppError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public isOperational = true
  ) {
    super(message);
    Object.setPrototypeOf(this, AppError.prototype);
  }
}

export const errorHandler = (
  err: Error | AppError,
  req: Request,
  res: Response,
  _next: NextFunction
) => {
  if (err instanceof AppError) {
    logger.error(
      `${err.statusCode} - ${err.message} - ${req.originalUrl} - ${req.method}`
    );
    res.status(err.statusCode).json({
      error: err.message,
      code: err.statusCode,
    });
    return;
  }

  // Prisma errors
  if (err.name === "PrismaClientKnownRequestError") {
    logger.error(`Prisma Error: ${err.message}`);
    res.status(400).json({
      error: "Database operation failed",
      code: "DB_ERROR",
    });
    return;
  }

  // Default error
  logger.error(
    `500 - ${err.message} - ${req.originalUrl} - ${req.method}`,
    err
  );
  res.status(500).json({
    error: "Internal server error",
    code: "INTERNAL_ERROR",
  });
};

export const asyncHandler = (fn: Function) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};
