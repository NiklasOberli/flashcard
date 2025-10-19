import nodemailer from 'nodemailer';

export interface EmailOptions {
  to: string;
  subject: string;
  html: string;
}

/**
 * Create email transporter based on environment configuration
 */
function createTransporter() {
  // In development, use Ethereal (fake SMTP service) if no real SMTP is configured
  if (process.env.NODE_ENV === 'development' && !process.env.SMTP_HOST) {
    return nodemailer.createTransport({
      host: 'smtp.ethereal.email',
      port: 587,
      secure: false,
      auth: {
        user: process.env.SMTP_USER || 'ethereal.user@ethereal.email',
        pass: process.env.SMTP_PASS || 'ethereal-password',
      },
    });
  }

  // Production or configured SMTP
  return nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT || '587'),
    secure: process.env.SMTP_SECURE === 'true',
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });
}

/**
 * Send an email
 */
export async function sendEmail(options: EmailOptions): Promise<void> {
  const transporter = createTransporter();
  
  const mailOptions = {
    from: process.env.EMAIL_FROM || 'Flashcard App <noreply@flashcard.app>',
    to: options.to,
    subject: options.subject,
    html: options.html,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    
    // In development, log the preview URL
    if (process.env.NODE_ENV === 'development') {
      console.log('Preview URL: %s', nodemailer.getTestMessageUrl(info));
    }
    
    console.log('Email sent: %s', info.messageId);
  } catch (error) {
    console.error('Error sending email:', error);
    throw new Error('Failed to send email');
  }
}

/**
 * Send email verification email
 */
export async function sendVerificationEmail(
  email: string,
  token: string
): Promise<void> {
  const verificationUrl = `${process.env.FRONTEND_URL || 'http://localhost:5173'}/verify-email?token=${token}`;
  
  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <h1 style="color: #333;">Welcome to Flashcard App!</h1>
      <p>Thank you for signing up. Please verify your email address by clicking the button below:</p>
      <a href="${verificationUrl}" style="display: inline-block; padding: 12px 24px; margin: 16px 0; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 4px;">
        Verify Email Address
      </a>
      <p>Or copy and paste this link into your browser:</p>
      <p style="word-break: break-all; color: #666;">${verificationUrl}</p>
      <p style="color: #999; font-size: 12px; margin-top: 32px;">
        If you didn't create an account, you can safely ignore this email.
      </p>
    </div>
  `;

  await sendEmail({
    to: email,
    subject: 'Verify Your Email Address',
    html,
  });
}

/**
 * Send password reset email
 */
export async function sendPasswordResetEmail(
  email: string,
  token: string
): Promise<void> {
  const resetUrl = `${process.env.FRONTEND_URL || 'http://localhost:5173'}/reset-password?token=${token}`;
  
  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <h1 style="color: #333;">Password Reset Request</h1>
      <p>You requested to reset your password. Click the button below to set a new password:</p>
      <a href="${resetUrl}" style="display: inline-block; padding: 12px 24px; margin: 16px 0; background-color: #2196F3; color: white; text-decoration: none; border-radius: 4px;">
        Reset Password
      </a>
      <p>Or copy and paste this link into your browser:</p>
      <p style="word-break: break-all; color: #666;">${resetUrl}</p>
      <p style="color: #ff9800; margin-top: 16px;">
        <strong>This link will expire in 24 hours.</strong>
      </p>
      <p style="color: #999; font-size: 12px; margin-top: 32px;">
        If you didn't request a password reset, you can safely ignore this email.
      </p>
    </div>
  `;

  await sendEmail({
    to: email,
    subject: 'Reset Your Password',
    html,
  });
}
