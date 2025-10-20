# Testing Guide

## Quick Start

### Prerequisites
1. Database must be running:
   ```powershell
   docker ps  # Check if PostgreSQL container is running
   # If not: docker-compose up -d
   ```

2. Backend server must be running:
   ```powershell
   cd backend
   npm run dev
   ```

### Run Automated Tests

```powershell
.\test-auth.ps1
```

This will run all authentication tests and show you exactly what passed or failed.

**Expected output:**
```
======================================================================
  FLASHCARD AUTHENTICATION TEST SUITE
======================================================================

📧 Test Email: test1234@example.com

Test: Server Health Check
Expected: Server responds with API message
✅ PASSED

Test: User Registration (Valid)
Expected: 201 Created - User registered successfully
✅ PASSED

... (all tests)

======================================================================
  TEST RESULTS SUMMARY
======================================================================

✅ ALL TESTS PASSED! (8/8)
```

## What Gets Tested

1. **Server Health** - Verifies backend is running
2. **User Registration** - Creates user with valid credentials
3. **Duplicate Email** - Rejects duplicate registrations (409)
4. **Weak Password** - Rejects passwords that don't meet requirements (400)
5. **Password Validation** - Tests uppercase/number requirements (400)
6. **Unverified Login** - Blocks login before email verification (403)
7. **Invalid Credentials** - Rejects wrong password (401)
8. **Forgot Password** - Password reset request works (200)

## Manual Testing (Advanced)

For testing features that require email verification tokens:

### 1. View Database Records
```powershell
cd backend
npm run db:studio
```
Opens Prisma Studio at http://localhost:5555

### 2. Get Verification Token
- Open Prisma Studio
- Click on "User" model
- Find your test user
- Copy the `verificationToken` value

### 3. Test Email Verification
```powershell
$token = "YOUR_TOKEN_HERE"
Invoke-RestMethod -Uri "http://localhost:3001/api/auth/verify-email?token=$token"
```

### 4. Test Login After Verification
```powershell
$body = @{ email = "test1234@example.com"; password = "TestPass123" } | ConvertTo-Json
$response = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/login" `
    -Method Post -ContentType "application/json" -Body $body
Write-Host "Token: $($response.token)"
```

### 5. Test Protected Routes
```powershell
$token = "YOUR_JWT_TOKEN_HERE"
Invoke-RestMethod -Uri "http://localhost:3001/api/protected-route" `
    -Headers @{ Authorization = "Bearer $token" }
```

## Password Requirements

Passwords must have:
- ✅ Minimum 8 characters
- ✅ At least one uppercase letter (A-Z)
- ✅ At least one lowercase letter (a-z)
- ✅ At least one number (0-9)

Examples:
- ✅ `TestPass123` - Valid
- ✅ `MySecureP4ss` - Valid
- ❌ `short` - Too short
- ❌ `nouppercase123` - No uppercase
- ❌ `NOLOWERCASE123` - No lowercase
- ❌ `NoNumbers` - No number

## Troubleshooting

### Server not responding
```powershell
# Check if backend is running
Test-NetConnection -ComputerName localhost -Port 3001 -InformationLevel Quiet

# If False, start the backend
cd backend
npm run dev
```

### Database not running
```powershell
# Check Docker containers
docker ps

# Start database
docker-compose up -d

# Check database logs
docker-compose logs -f
```

### Tests failing after changes
1. Check `get_errors` in VS Code for TypeScript errors
2. Review backend console for runtime errors
3. Verify `.env` file has correct `DATABASE_URL` and `JWT_SECRET`
4. Run Prisma migrations: `cd backend ; npx prisma migrate dev`

## API Endpoints Reference

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/verify-email?token=XXX` - Verify email
- `POST /api/auth/resend-verification` - Resend verification email
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password` - Reset password with token

### Request Examples

**Register:**
```json
POST /api/auth/register
{
  "email": "user@example.com",
  "password": "TestPass123"
}
```

**Login:**
```json
POST /api/auth/login
{
  "email": "user@example.com",
  "password": "TestPass123"
}
```

**Response:**
```json
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": "550e8400-e29b-41d4-a716-446655440000"
}
```

## Files

- `test-auth.ps1` - Main test suite (run this!)
- `backend/AUTHENTICATION_README.md` - Implementation details
- `backend/src/routes/auth.ts` - Auth endpoints source code
- `backend/prisma/schema.prisma` - Database schema

## Need Help?

1. Check the backend console for errors
2. Review `backend/AUTHENTICATION_README.md` for implementation details
3. Use Prisma Studio to inspect database state
4. Check email preview URLs in backend console (for Ethereal email testing)
