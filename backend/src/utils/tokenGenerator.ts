import crypto from 'crypto';

/**
 * Generate a secure random token for email verification or password reset
 * @param length - Length of the token in bytes (default: 32)
 * @returns Hexadecimal string token
 */
export function generateToken(length: number = 32): string {
  return crypto.randomBytes(length).toString('hex');
}

/**
 * Generate expiry time for reset tokens
 * @param hours - Number of hours until expiry (default: 24)
 * @returns Date object representing the expiry time
 */
export function generateTokenExpiry(hours: number = 24): Date {
  const expiry = new Date();
  expiry.setHours(expiry.getHours() + hours);
  return expiry;
}
