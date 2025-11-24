import swaggerJsdoc from "swagger-jsdoc";
import swaggerUi from "swagger-ui-express";
import { Express } from "express";

const options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "Repair Shop API",
      version: "1.0.0",
      description: "API documentation for the Repair Shop Management System",
    },
    servers: [
      {
        url: "http://localhost:8080/api",
      },
    ],
  },
  // Path to the API docs
  apis: ["./src/routes/*.ts", "./src/controllers/*.ts"],
};

const swaggerSpec = swaggerJsdoc(options);

export function setupSwagger(app: Express) {
  app.use("/docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));
}

export default swaggerSpec;
