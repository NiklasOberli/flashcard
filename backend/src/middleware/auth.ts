import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export interface AuthRequest extends Request {
  userId?: string;
}

export interface JwtPayload {
  userId: string;
}

/**
 * Middleware to verify JWT token and attach userId to request
 */
export async function authenticateToken(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      res.status(401).json({ error: 'Access token required' });
      return;
    }

    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) {
      console.error('JWT_SECRET is not defined in environment variables');
      res.status(500).json({ error: 'Server configuration error' });
      return;
    }

    const decoded = jwt.verify(token, jwtSecret) as JwtPayload;
    req.userId = decoded.userId;
    next();
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      res.status(403).json({ error: 'Invalid or expired token' });
      return;
    }
    res.status(500).json({ error: 'Authentication failed' });
  }
}

/**
 * Generate JWT token for a user
 */
export function generateAuthToken(userId: string): string {
  const jwtSecret = process.env.JWT_SECRET;
  if (!jwtSecret) {
    throw new Error('JWT_SECRET is not defined in environment variables');
  }

  return jwt.sign(
    { userId },
    jwtSecret,
    { expiresIn: '7d' }
  );
}
