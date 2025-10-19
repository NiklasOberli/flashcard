import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';
import { validatePassword } from '../utils/passwordValidation';
import { generateToken, generateTokenExpiry } from '../utils/tokenGenerator';
import {
  sendVerificationEmail,
  sendPasswordResetEmail,
} from '../utils/emailService';
import { generateAuthToken } from '../middleware/auth';

const router = Router();
const prisma = new PrismaClient();

/**
 * POST /api/auth/register
 * Register a new user
 */
router.post('/register', async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      res.status(400).json({ error: 'Email and password are required' });
      return;
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      res.status(400).json({ error: 'Invalid email format' });
      return;
    }

    // Validate password strength
    const passwordValidation = validatePassword(password);
    if (!passwordValidation.isValid) {
      res.status(400).json({
        error: 'Password does not meet requirements',
        details: passwordValidation.errors,
      });
      return;
    }

    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: { email: email.toLowerCase() },
    });

    if (existingUser) {
      res.status(409).json({ error: 'Email already registered' });
      return;
    }

    // Hash password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Generate verification token
    const verificationToken = generateToken();

    // Create user
    const user = await prisma.user.create({
      data: {
        email: email.toLowerCase(),
        passwordHash,
        verificationToken,
        emailVerified: false,
      },
    });

    // Send verification email
    try {
      await sendVerificationEmail(user.email, verificationToken);
    } catch (emailError) {
      console.error('Failed to send verification email:', emailError);
      // Continue even if email fails - user can request resend
    }

    res.status(201).json({
      message: 'User registered successfully. Please check your email to verify your account.',
      userId: user.id,
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Failed to register user' });
  }
});

/**
 * POST /api/auth/login
 * Authenticate user and return JWT token
 */
router.post('/login', async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      res.status(400).json({ error: 'Email and password are required' });
      return;
    }

    // Find user
    const user = await prisma.user.findUnique({
      where: { email: email.toLowerCase() },
    });

    if (!user) {
      res.status(401).json({ error: 'Invalid email or password' });
      return;
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      res.status(401).json({ error: 'Invalid email or password' });
      return;
    }

    // Check if email is verified
    if (!user.emailVerified) {
      res.status(403).json({
        error: 'Email not verified',
        message: 'Please verify your email address before logging in',
      });
      return;
    }

    // Generate JWT token
    const token = generateAuthToken(user.id);

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        email: user.email,
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Failed to login' });
  }
});

/**
 * GET /api/auth/verify-email?token=xxx
 * Verify user's email address
 */
router.get('/verify-email', async (req: Request, res: Response) => {
  try {
    const { token } = req.query;

    if (!token || typeof token !== 'string') {
      res.status(400).json({ error: 'Verification token is required' });
      return;
    }

    // Find user with this verification token
    const user = await prisma.user.findUnique({
      where: { verificationToken: token },
    });

    if (!user) {
      res.status(404).json({ error: 'Invalid or expired verification token' });
      return;
    }

    // Check if already verified
    if (user.emailVerified) {
      res.status(400).json({ error: 'Email already verified' });
      return;
    }

    // Update user to verified
    await prisma.user.update({
      where: { id: user.id },
      data: {
        emailVerified: true,
        verificationToken: null,
      },
    });

    res.json({ message: 'Email verified successfully. You can now login.' });
  } catch (error) {
    console.error('Email verification error:', error);
    res.status(500).json({ error: 'Failed to verify email' });
  }
});

/**
 * POST /api/auth/resend-verification
 * Resend verification email
 */
router.post('/resend-verification', async (req: Request, res: Response) => {
  try {
    const { email } = req.body;

    if (!email) {
      res.status(400).json({ error: 'Email is required' });
      return;
    }

    // Find user
    const user = await prisma.user.findUnique({
      where: { email: email.toLowerCase() },
    });

    if (!user) {
      // Don't reveal if user exists
      res.json({ message: 'If the email exists, a verification email will be sent.' });
      return;
    }

    // Check if already verified
    if (user.emailVerified) {
      res.status(400).json({ error: 'Email already verified' });
      return;
    }

    // Generate new verification token
    const verificationToken = generateToken();

    // Update user with new token
    await prisma.user.update({
      where: { id: user.id },
      data: { verificationToken },
    });

    // Send verification email
    await sendVerificationEmail(user.email, verificationToken);

    res.json({ message: 'Verification email sent successfully.' });
  } catch (error) {
    console.error('Resend verification error:', error);
    res.status(500).json({ error: 'Failed to resend verification email' });
  }
});

/**
 * POST /api/auth/forgot-password
 * Request password reset
 */
router.post('/forgot-password', async (req: Request, res: Response) => {
  try {
    const { email } = req.body;

    if (!email) {
      res.status(400).json({ error: 'Email is required' });
      return;
    }

    // Find user
    const user = await prisma.user.findUnique({
      where: { email: email.toLowerCase() },
    });

    // Don't reveal if user exists for security
    if (!user) {
      res.json({
        message: 'If the email exists, a password reset link will be sent.',
      });
      return;
    }

    // Generate reset token and expiry
    const resetToken = generateToken();
    const resetTokenExpiry = generateTokenExpiry(24); // 24 hours

    // Update user with reset token
    await prisma.user.update({
      where: { id: user.id },
      data: {
        resetToken,
        resetTokenExpiry,
      },
    });

    // Send password reset email
    await sendPasswordResetEmail(user.email, resetToken);

    res.json({
      message: 'If the email exists, a password reset link will be sent.',
    });
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({ error: 'Failed to process password reset request' });
  }
});

/**
 * POST /api/auth/reset-password
 * Reset password with token
 */
router.post('/reset-password', async (req: Request, res: Response) => {
  try {
    const { token, newPassword } = req.body;

    if (!token || !newPassword) {
      res.status(400).json({ error: 'Token and new password are required' });
      return;
    }

    // Validate password strength
    const passwordValidation = validatePassword(newPassword);
    if (!passwordValidation.isValid) {
      res.status(400).json({
        error: 'Password does not meet requirements',
        details: passwordValidation.errors,
      });
      return;
    }

    // Find user with this reset token
    const user = await prisma.user.findUnique({
      where: { resetToken: token },
    });

    if (!user || !user.resetTokenExpiry) {
      res.status(404).json({ error: 'Invalid or expired reset token' });
      return;
    }

    // Check if token is expired
    if (new Date() > user.resetTokenExpiry) {
      res.status(400).json({ error: 'Reset token has expired' });
      return;
    }

    // Hash new password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(newPassword, saltRounds);

    // Update user password and clear reset token
    await prisma.user.update({
      where: { id: user.id },
      data: {
        passwordHash,
        resetToken: null,
        resetTokenExpiry: null,
      },
    });

    res.json({ message: 'Password reset successfully. You can now login.' });
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({ error: 'Failed to reset password' });
  }
});

export default router;
