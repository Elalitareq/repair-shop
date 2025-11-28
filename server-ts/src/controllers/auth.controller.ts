import { Request, Response } from "express";
import { validationResult } from "express-validator";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { AppError } from "../middleware/errorHandler";
import { prisma } from "../utils/prisma";

export class AuthController {
  async login(req: Request, res: Response) {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw new AppError(400, errors.array()[0].msg);
    }

    const { username_or_email: username, password } = req.body;

    console.log("User not found for username:", username);
    const user = await prisma.user.findUnique({
      where: { username },
    });

    console.log("User not found for username:", user);
    if (!user) {
      throw new AppError(401, "Invalid credentials");
    }

    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      throw new AppError(401, "Invalid credentials");
    }
    const secret = process.env.JWT_SECRET!;
    const token = jwt.sign(
      {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
      },
      secret,
      { expiresIn: "24h" }
    );

    const refreshToken = jwt.sign({ id: user.id }, secret, {
      expiresIn: "7d",
    });

    res.json({
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        isActive: true,
      },
      token,
      refresh_token: refreshToken,
    });
  }

  async register(req: Request, res: Response) {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw new AppError(400, errors.array()[0].msg);
    }

    const { username, email, password, role } = req.body;

    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [{ username }, { email }],
      },
    });

    if (existingUser) {
      throw new AppError(409, "Username or email already exists");
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await prisma.user.create({
      data: {
        username,
        email,
        password: hashedPassword,
        role: role || "user",
      },
    });

    const secret = process.env.JWT_SECRET!;
    const token = jwt.sign(
      {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
      },
      secret,
      { expiresIn: "24h" }
    );

    res.status(201).json({
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        isActive: true,
      },
      token,
    });
  }

  async refresh(req: Request, res: Response) {
    const { refresh_token } = req.body;

    if (!refresh_token) {
      throw new AppError(400, "Refresh token is required");
    }

    try {
      const secret = process.env.JWT_SECRET!;
      const decoded = jwt.verify(refresh_token, secret) as any;

      const user = await prisma.user.findUnique({
        where: { id: decoded.id },
      });

      if (!user) {
        throw new AppError(401, "Invalid refresh token");
      }

      const newToken = jwt.sign(
        {
          id: user.id,
          username: user.username,
          email: user.email,
          role: user.role,
        },
        secret,
        { expiresIn: "24h" }
      );

      res.json({ token: newToken });
    } catch (error) {
      throw new AppError(401, "Invalid refresh token");
    }
  }
}
