import app from "./app";
import { logger } from "./utils/logger";
import { prisma } from "./utils/prisma";

const PORT = process.env.PORT || 8080;

// Start server (only when not running tests)
if (process.env.NODE_ENV !== "test") {
  const server = app.listen(PORT, () => {
    logger.info(`🚀 Server running on port ${PORT}`);
    logger.info(`📊 Health check: http://localhost:${PORT}/health`);
    logger.info(`🔧 Environment: ${process.env.NODE_ENV || "development"}`);
  });

  // Graceful shutdown
  process.on("SIGTERM", async () => {
    logger.info("SIGTERM received, shutting down gracefully");
    server.close(() => {
      logger.info("Server closed");
    });
    await prisma.$disconnect();
    process.exit(0);
  });

  process.on("SIGINT", async () => {
    logger.info("SIGINT received, shutting down gracefully");
    server.close(() => {
      logger.info("Server closed");
    });
    await prisma.$disconnect();
    process.exit(0);
  });
}
