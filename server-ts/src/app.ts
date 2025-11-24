import express, { Express } from "express";
import cors from "cors";
import dotenv from "dotenv";
import { errorHandler } from "./middleware/errorHandler";
import { logger } from "./utils/logger";
import routes from "./routes";
import { setupSwagger } from "./docs/swagger";

dotenv.config();

const app: Express = express();

app.use(cors({}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use((req, _res, next) => {
  logger.info(`${req.method} ${req.path}`);
  next();
});

// Health check
app.get("/health", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

// Swagger docs
setupSwagger(app);

// API routes
app.use("/api", routes);

// Error handling
app.use(errorHandler);

export default app;
