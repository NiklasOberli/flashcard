# Authentication System Testing Guide

## Overview
The authentication system has been implemented with comprehensive testing support. All endpoints are designed to be easily testable using tools like Postman, cURL, or automated test frameworks.

## Environment Setup for Testing

1. **Copy the environment template:**
   ```bash
   cd backend
   cp .env.example .env
   ```

2. **Update the `.env` file with your settings:**
   - Set a strong `JWT_SECRET`
   - Configure email service (or use Ethereal for testing)

3. **Start the database:**
   ```bash
   docker-compose up -d
   ```

4. **Run database migrations:**
   ```bash
   cd backend
   npm run db:push
   ```

5. **Start the backend server:**
   ```bash
   npm run dev
   ```

## API Endpoints for Testing

Base URL: `http://localhost:3001/api/auth`

### 1. Register a New User

**Endpoint:** `POST /api/auth/register`

**Request Body:**
```json
{
  "email": "test@example.com",
  "password": "TestPass123"
}
```

**Password Requirements:**
- At least 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number

**Success Response (201):**
```json
{
  "message": "User registered successfully. Please check your email to verify your account.",
  "userId": "uuid-here"
}
```

**Error Responses:**
- 400: Invalid input or password doesn't meet requirements
- 409: Email already registered

### 2. Verify Email

**Endpoint:** `GET /api/auth/verify-email?token=TOKEN_FROM_EMAIL`

**Success Response (200):**
```json
{
  "message": "Email verified successfully. You can now login."
}
```

**Error Responses:**
- 400: Invalid token or already verified
- 404: Token not found

### 3. Resend Verification Email

**Endpoint:** `POST /api/auth/resend-verification`

**Request Body:**
```json
{
  "email": "test@example.com"
}
```

**Success Response (200):**
```json
{
  "message": "Verification email sent successfully."
}
```

### 4. Login

**Endpoint:** `POST /api/auth/login`

**Request Body:**
```json
{
  "email": "test@example.com",
  "password": "TestPass123"
}
```

**Success Response (200):**
```json
{
  "message": "Login successful",
  "token": "jwt-token-here",
  "user": {
    "id": "uuid-here",
    "email": "test@example.com"
  }
}
```

**Error Responses:**
- 401: Invalid email or password
- 403: Email not verified

### 5. Forgot Password

**Endpoint:** `POST /api/auth/forgot-password`

**Request Body:**
```json
{
  "email": "test@example.com"
}
```

**Success Response (200):**
```json
{
  "message": "If the email exists, a password reset link will be sent."
}
```

### 6. Reset Password

**Endpoint:** `POST /api/auth/reset-password`

**Request Body:**
```json
{
  "token": "reset-token-from-email",
  "newPassword": "NewPass123"
}
```

**Success Response (200):**
```json
{
  "message": "Password reset successfully. You can now login."
}
```

**Error Responses:**
- 400: Invalid token or password doesn't meet requirements
- 404: Token not found or expired

## Testing with cURL

### Register a User
```bash
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"TestPass123"}'
```

### Login
```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"TestPass123"}'
```

### Test Protected Route (example)
```bash
curl -X GET http://localhost:3001/api/protected-route \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Testing with Postman

1. Import the endpoints into Postman
2. Create a Postman Collection for all auth endpoints
3. Use Postman environment variables to store the JWT token
4. Test the complete flow: Register → Verify → Login → Reset Password

## Automated Testing

### Unit Tests (Future Implementation)
Consider using Jest or Mocha for unit testing:
- Password validation logic
- Token generation
- Email service mocking

### Integration Tests (Future Implementation)
Use Supertest for API endpoint testing:
- Complete registration flow
- Login with correct/incorrect credentials
- Email verification flow
- Password reset flow

### Example Test Structure
```typescript
// tests/auth.test.ts
describe('Authentication API', () => {
  describe('POST /api/auth/register', () => {
    it('should register a new user with valid data', async () => {
      // Test implementation
    });
    
    it('should reject weak passwords', async () => {
      // Test implementation
    });
    
    it('should reject duplicate emails', async () => {
      // Test implementation
    });
  });
  
  describe('POST /api/auth/login', () => {
    it('should login with verified email', async () => {
      // Test implementation
    });
    
    it('should reject unverified email', async () => {
      // Test implementation
    });
  });
});
```

## Email Testing

### Development: Using Ethereal Email
1. Create a free account at https://ethereal.email/
2. Use the SMTP credentials in your `.env` file
3. Check console output for preview URLs of sent emails
4. Click the preview URL to see the email content

### Alternative: Use Mailtrap
1. Sign up at https://mailtrap.io/
2. Use Mailtrap SMTP credentials
3. View all test emails in the Mailtrap inbox

## Security Testing Checklist

- [ ] Verify email uniqueness is enforced
- [ ] Confirm password requirements are validated
- [ ] Test JWT token expiration
- [ ] Verify reset tokens expire after 24 hours
- [ ] Check that unverified users cannot login
- [ ] Test rate limiting (if implemented)
- [ ] Verify CORS settings
- [ ] Test SQL injection prevention
- [ ] Check XSS protection
- [ ] Verify password hashing (bcrypt)

## Common Testing Scenarios

1. **Happy Path:**
   - Register → Verify Email → Login → Access Protected Routes

2. **Email Verification:**
   - Register → Try Login Before Verification (should fail) → Verify → Login (should succeed)

3. **Password Reset:**
   - Register → Verify → Login → Forgot Password → Reset Password → Login with New Password

4. **Error Cases:**
   - Weak password registration
   - Duplicate email registration
   - Invalid credentials login
   - Expired reset token

## Notes

- Email links work in development when using `http://localhost:5173` as `FRONTEND_URL`
- In development, email preview URLs are logged to the console
- All passwords are hashed with bcrypt (10 salt rounds)
- JWT tokens expire after 7 days by default (configurable)
- Reset tokens expire after 24 hours
