# Authentication System

## Overview

A complete authentication system with email verification, password reset, and JWT token management.

### Features
- User registration with email validation
- Password strength validation (min 8 chars, uppercase, lowercase, number)
- Email verification with secure tokens
- Login with JWT tokens (7-day expiry)
- Password reset flow
- Resend verification email
- JWT authentication middleware for protected routes

## Database Schema

```prisma
model User {
  id                  String      @id @default(uuid())
  email               String      @unique
  passwordHash        String
  emailVerified       Boolean     @default(false)
  verificationToken   String?     @unique
  resetToken          String?     @unique
  resetTokenExpiry    DateTime?
  createdAt           DateTime    @default(now())
  updatedAt           DateTime    @updatedAt
  
  folders             Folder[]
  flashcards          Flashcard[]
}
```

## API Endpoints

Base URL: `/api/auth`

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|---------------|
| `/register` | POST | Register new user | No |
| `/login` | POST | Login and get JWT token | No |
| `/verify-email` | GET | Verify email with token | No |
| `/resend-verification` | POST | Resend verification email | No |
| `/forgot-password` | POST | Request password reset | No |
| `/reset-password` | POST | Reset password with token | No |

### Request/Response Examples

**Register User**
```bash
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123"
}

# Response (201)
{
  "message": "User registered successfully. Please check your email to verify your account.",
  "userId": "uuid-here"
}
```

**Login**
```bash
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123"
}

# Response (200)
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid-here",
    "email": "user@example.com"
  }
}
```

**Verify Email**
```bash
GET /api/auth/verify-email?token=VERIFICATION_TOKEN

# Response (200)
{
  "message": "Email verified successfully. You can now login."
}
```

**Forgot Password**
```bash
POST /api/auth/forgot-password
Content-Type: application/json

{
  "email": "user@example.com"
}

# Response (200)
{
  "message": "If the email exists, a password reset link will be sent."
}
```

**Reset Password**
```bash
POST /api/auth/reset-password
Content-Type: application/json

{
  "token": "reset-token-from-email",
  "newPassword": "NewSecurePass123"
}

# Response (200)
{
  "message": "Password reset successfully. You can now login."
}
```

## Environment Variables

Required environment variables in `backend/.env`:

```bash
# JWT Configuration
JWT_SECRET=your-secret-key-here-change-this-in-production
JWT_EXPIRY=7d

# Frontend URL (for email links)
FRONTEND_URL=http://localhost:5173

# Email Service Configuration
SMTP_HOST=smtp.ethereal.email
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-ethereal-username
SMTP_PASS=your-ethereal-password
EMAIL_FROM=Flashcard App <noreply@flashcard.app>
```

## Password Requirements

Passwords must meet these requirements:
- ✅ Minimum 8 characters
- ✅ At least one uppercase letter (A-Z)
- ✅ At least one lowercase letter (a-z)
- ✅ At least one number (0-9)

**Valid Examples:**
- `TestPass123`
- `MySecureP4ss`
- `Welcome2024`

**Invalid Examples:**
- `short` (too short)
- `nouppercase123` (no uppercase)
- `NOLOWERCASE123` (no lowercase)
- `NoNumbers` (no number)

## Testing

### Quick Test with PowerShell

```powershell
# Register a new user
$body = @{
    email = "test@example.com"
    password = "TestPass123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3001/api/auth/register" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

### Using the Test Script

Run the automated test suite:
```powershell
.\test-auth.ps1
```

This tests:
- Server health check
- User registration (valid)
- Duplicate email rejection (409)
- Weak password rejection (400)
- Password validation rules (400)
- Unverified login blocking (403)
- Invalid credentials rejection (401)
- Forgot password flow (200)

### Manual Testing with Prisma Studio

View and manage database records:
```powershell
cd backend
npm run db:studio
```

Access at http://localhost:5555 to:
- View all users
- Copy verification/reset tokens for testing
- Check email verification status
- Manually update fields if needed

### Email Testing

**Development (Ethereal Email):**
1. Create free account at https://ethereal.email/
2. Add SMTP credentials to `.env`
3. Check backend console for email preview URLs
4. Click preview URL to view sent emails

**Alternative (Mailtrap):**
1. Sign up at https://mailtrap.io/
2. Use Mailtrap SMTP credentials in `.env`
3. View all test emails in Mailtrap inbox

## Security Features

✅ **Implemented:**
- Passwords hashed with bcrypt (10 salt rounds)
- JWT tokens with configurable expiration
- Email uniqueness enforcement
- Secure token generation using crypto
- Token expiration for reset tokens (24 hours)
- Email verification requirement before login
- SQL injection prevention via Prisma
- XSS protection via proper input validation

## Using Protected Routes

To protect API routes, use the `authenticateToken` middleware:

```typescript
import { authenticateToken, AuthRequest } from '../middleware/auth';

router.get('/protected', authenticateToken, async (req: AuthRequest, res) => {
  const userId = req.userId; // Available after authentication
  // Your protected route logic here
});
```

**Making authenticated requests:**
```bash
curl -X GET http://localhost:3001/api/protected-route \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Error Responses

All endpoints return consistent error formats:

```json
{
  "error": "Error message",
  "details": ["Optional array of detailed errors"]
}
```

**HTTP Status Codes:**
- `200` - Success
- `201` - Created (registration)
- `400` - Bad request (validation errors)
- `401` - Unauthorized (invalid credentials)
- `403` - Forbidden (unverified email, invalid token)
- `404` - Not found (user/token not found)
- `409` - Conflict (duplicate email)
- `500` - Server error

## Frontend Integration

### Registration Flow
1. Show password requirements on registration page
2. Display success message with verification instruction
3. Provide "Resend verification email" option

### Login Flow
1. Store JWT token (localStorage or httpOnly cookie)
2. Handle unverified email error (403)
3. Redirect to dashboard on success

### Email Verification
1. Create `/verify-email` route in frontend
2. Extract token from URL query parameter
3. Call verification endpoint
4. Show success/error message
5. Redirect to login on success

### Password Reset
1. Create forgot password page
2. Create reset password page with token parameter
3. Show password requirements
4. Redirect to login on success

### Authenticated Requests
1. Add `Authorization: Bearer <token>` header to all API calls
2. Implement token refresh logic
3. Handle 401/403 errors (redirect to login)
4. Clear token on logout

## Troubleshooting

**Server not responding:**
```powershell
# Check if backend is running
Test-NetConnection -ComputerName localhost -Port 3001 -InformationLevel Quiet

# Start backend if needed
cd backend
npm run dev
```

**Database connection error:**
```powershell
# Check Docker containers
docker ps

# Start database
docker-compose up -d

# Check logs
docker-compose logs -f
```

**Prisma client issues:**
```powershell
cd backend
npm run db:generate
npm run db:push
```

**Port already in use:**
```powershell
Get-Process -Name node | Stop-Process -Force
```

## File Structure

```
backend/
├── src/
│   ├── routes/
│   │   └── auth.ts                 # Authentication endpoints
│   ├── middleware/
│   │   └── auth.ts                 # JWT authentication middleware
│   ├── utils/
│   │   ├── passwordValidation.ts   # Password strength validator
│   │   ├── tokenGenerator.ts       # Secure token generation
│   │   └── emailService.ts         # Email sending functionality
│   └── index.ts                    # Express app setup
└── prisma/
    └── schema.prisma               # Database schema
```

## Next Steps

- Implement rate limiting on auth endpoints
- Add account lockout after failed attempts
- Consider two-factor authentication (2FA)
- Add OAuth integration (Google, GitHub)
- Implement session management
- Add password history tracking
- Set up security audit logging
