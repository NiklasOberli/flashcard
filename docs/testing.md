# Testing Guide

## Quick Start

### Prerequisites

1. **Database must be running:**
   ```powershell
   docker ps  # Check if PostgreSQL container is running
   # If not: docker-compose up -d
   ```

2. **Backend server must be running:**
   ```powershell
   cd backend
   npm run dev
   ```

### Run Automated Tests

```powershell
.\test-auth.ps1
```

This runs all authentication tests and displays results.

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

The test suite covers:

1. **Server Health** - Verifies backend is running
2. **User Registration** - Creates user with valid credentials
3. **Duplicate Email** - Rejects duplicate registrations (409)
4. **Weak Password** - Rejects passwords that don't meet requirements (400)
5. **Password Validation** - Tests uppercase/number requirements (400)
6. **Unverified Login** - Blocks login before email verification (403)
7. **Invalid Credentials** - Rejects wrong password (401)
8. **Forgot Password** - Password reset request works (200)

## Manual Testing

For features requiring email verification tokens:

### 1. Open Prisma Studio
```powershell
cd backend
npm run db:studio
```
Access at http://localhost:5555

### 2. Get Tokens
- Click "User" model
- Find your test user
- Copy `verificationToken` or `resetToken` for testing

### 3. Test Email Verification
```powershell
$token = "YOUR_TOKEN_HERE"
Invoke-RestMethod -Uri "http://localhost:3001/api/auth/verify-email?token=$token"
```

### 4. Test Login After Verification
```powershell
$body = @{ email = "test@example.com"; password = "TestPass123" } | ConvertTo-Json
$response = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/login" `
    -Method Post -ContentType "application/json" -Body $body
Write-Host "JWT Token: $($response.token)"
```

### 5. Test Protected Routes
```powershell
$token = "YOUR_JWT_TOKEN"
Invoke-RestMethod -Uri "http://localhost:3001/api/protected-route" `
    -Headers @{ Authorization = "Bearer $token" }
```

## Testing Tools

### PowerShell (Built-in)
Use `Invoke-RestMethod` for quick API tests (see examples above).

### Postman
1. Import collection or create requests manually
2. Use environment variables for base URL and tokens
3. Chain requests (register → verify → login)

### VS Code REST Client Extension
1. Install "REST Client" extension
2. Create `.http` or `.rest` files with requests
3. Click "Send Request" above each request

Example `test.http`:
```http
### Register User
POST http://localhost:3001/api/auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "TestPass123"
}

### Login
POST http://localhost:3001/api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "TestPass123"
}
```

## Troubleshooting

### Server not responding
```powershell
# Check if backend is running on port 3001
Test-NetConnection -ComputerName localhost -Port 3001 -InformationLevel Quiet

# Start backend if needed
cd backend
npm run dev
```

### Database not running
```powershell
# Check Docker containers
docker ps

# Start database
docker-compose up -d

# View logs
docker-compose logs -f
```

### Tests failing after changes
1. Check for TypeScript errors in VS Code Problems panel
2. Review backend console for runtime errors
3. Verify `.env` has `DATABASE_URL` and `JWT_SECRET`
4. Regenerate Prisma client: `cd backend ; npm run db:generate`

### Prisma client issues
```powershell
cd backend
npm run db:generate
npm run db:push
```

### Port already in use
```powershell
# Kill all Node processes
Get-Process -Name node | Stop-Process -Force
```

## Documentation References

- **[Authentication Guide](./authentication.md)** - Complete authentication system documentation
- **[API Endpoints](./api-endpoints.md)** - Full API reference
- **[Backend Setup](./backend-setup.md)** - Backend configuration and setup
- **[Database Schema](./database-schema.md)** - Database structure and models

## Test Files

- `test-auth.ps1` - Automated authentication test suite (project root)
- `backend/src/routes/auth.ts` - Authentication endpoints source code
- `backend/prisma/schema.prisma` - Database schema
