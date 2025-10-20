# Quick Testing Guide for Authentication System

## Prerequisites Check

1. **Database is running:**
   ```powershell
   docker ps
   ```
   You should see the PostgreSQL container running.

2. **Environment variables are set:**
   ```powershell
   cd backend
   cat .env
   ```
   If `.env` doesn't exist, copy from example:
   ```powershell
   Copy-Item .env.example .env
   ```

3. **Edit your `.env` file** and set a JWT_SECRET:
   ```
   JWT_SECRET=my-super-secret-jwt-key-for-testing-12345
   ```

## Step 1: Start the Backend Server

```powershell
cd c:\Drive\Projects\Repos\flashcard\backend
npm run dev
```

The server should start at `http://localhost:3001`

## Step 2: Test with PowerShell (cURL alternative)

### Test 1: Register a User

```powershell
$body = @{
    email = "test@example.com"
    password = "TestPass123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3001/api/auth/register" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

**Expected Output:**
```
message : User registered successfully. Please check your email to verify your account.
userId  : [some-uuid]
```

### Test 2: Check Console for Verification Token

In the terminal where your backend is running, you should see:
```
Preview URL: https://ethereal.email/message/...
Email sent: ...
```

**Click that Preview URL** to see the verification email, or extract the token from the console/database.

### Test 3: Verify Email

Get the token from the email preview or database, then:

```powershell
# Replace TOKEN_HERE with actual token
Invoke-RestMethod -Uri "http://localhost:3001/api/auth/verify-email?token=TOKEN_HERE" `
    -Method Get
```

**Expected Output:**
```
message : Email verified successfully. You can now login.
```

### Test 4: Try Login (Should Fail Before Verification)

```powershell
$loginBody = @{
    email = "test@example.com"
    password = "TestPass123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3001/api/auth/login" `
    -Method Post `
    -ContentType "application/json" `
    -Body $loginBody
```

**Before verification:** Should return 403 error
**After verification:** Should return JWT token

### Test 5: Login Successfully

After email verification:

```powershell
$loginBody = @{
    email = "test@example.com"
    password = "TestPass123"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/login" `
    -Method Post `
    -ContentType "application/json" `
    -Body $loginBody

# Save the token
$token = $response.token
Write-Host "Token: $token"
```

### Test 6: Test Password Validation

Try registering with weak password:

```powershell
$weakPassword = @{
    email = "weak@example.com"
    password = "weak"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3001/api/auth/register" `
    -Method Post `
    -ContentType "application/json" `
    -Body $weakPassword
```

**Expected:** Should return 400 error with password requirement details

### Test 7: Test Duplicate Email

Try registering same email again:

```powershell
$body = @{
    email = "test@example.com"
    password = "TestPass123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3001/api/auth/register" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

**Expected:** Should return 409 error "Email already registered"

### Test 8: Test Forgot Password

```powershell
$forgotBody = @{
    email = "test@example.com"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3001/api/auth/forgot-password" `
    -Method Post `
    -ContentType "application/json" `
    -Body $forgotBody
```

**Expected:** Success message, check console for reset email preview URL

### Test 9: Reset Password

```powershell
$resetBody = @{
    token = "RESET_TOKEN_FROM_EMAIL"
    newPassword = "NewPass456"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3001/api/auth/reset-password" `
    -Method Post `
    -ContentType "application/json" `
    -Body $resetBody
```

### Test 10: Login with New Password

```powershell
$newLoginBody = @{
    email = "test@example.com"
    password = "NewPass456"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3001/api/auth/login" `
    -Method Post `
    -ContentType "application/json" `
    -Body $newLoginBody
```

## Alternative: Use Postman or REST Client Extension

### Option A: VS Code REST Client Extension

1. Install "REST Client" extension in VS Code
2. Create a file `test-auth.http` in your project
3. Use the examples below

### Option B: Postman

1. Open Postman
2. Import the collection (or create manually)
3. Test each endpoint

## Manual Database Verification

You can also check the database directly:

```powershell
cd c:\Drive\Projects\Repos\flashcard\backend
npm run db:studio
```

This opens Prisma Studio in your browser where you can:
- View all users
- Check emailVerified status
- See verification tokens
- Manually update fields for testing

## Getting Email Verification Tokens

### Method 1: Console Logs
Watch the backend console for preview URLs

### Method 2: Prisma Studio
```powershell
npm run db:studio
```
Open in browser, go to User table, find your user, copy the verificationToken

### Method 3: Query Database
```powershell
# In Prisma Studio or use psql
# Find the verification token for an email
```

## Common Issues & Solutions

**Issue:** "Cannot find module '@prisma/client'"
```powershell
npm run db:generate
```

**Issue:** Database connection error
```powershell
# Check if Docker is running
docker ps
# Restart database
docker-compose restart
```

**Issue:** Port 3001 already in use
```powershell
# Find and kill the process
Get-Process -Name node | Stop-Process -Force
```

**Issue:** Email not sending
- Check console for preview URLs (they should still appear)
- Emails are "sent" to Ethereal by default in development
- No real email setup needed for testing

## Complete Test Script

Save this as `test-auth.ps1`:

```powershell
# Test Authentication System

Write-Host "🚀 Testing Authentication System" -ForegroundColor Green

# 1. Register
Write-Host "`n📝 Test 1: Register new user" -ForegroundColor Yellow
$registerBody = @{
    email = "test$(Get-Random)@example.com"
    password = "TestPass123"
} | ConvertTo-Json

$registerResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/register" -Method Post -ContentType "application/json" -Body $registerBody
Write-Host "✅ Registration successful: $($registerResponse.message)" -ForegroundColor Green

# 2. Test weak password
Write-Host "`n🔒 Test 2: Reject weak password" -ForegroundColor Yellow
try {
    $weakBody = @{
        email = "weak@example.com"
        password = "weak"
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "http://localhost:3001/api/auth/register" -Method Post -ContentType "application/json" -Body $weakBody
} catch {
    Write-Host "✅ Weak password rejected (expected)" -ForegroundColor Green
}

# 3. Test duplicate email
Write-Host "`n👥 Test 3: Reject duplicate email" -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "http://localhost:3001/api/auth/register" -Method Post -ContentType "application/json" -Body $registerBody
} catch {
    Write-Host "✅ Duplicate email rejected (expected)" -ForegroundColor Green
}

Write-Host "`n✨ Basic tests completed!" -ForegroundColor Green
Write-Host "📧 Check your backend console for email verification link" -ForegroundColor Cyan
```

Run it:
```powershell
.\test-auth.ps1
```

## Summary

1. Start backend: `npm run dev`
2. Test endpoints with PowerShell commands above
3. Check console for email preview URLs
4. Verify tokens work correctly
5. Test all validation rules
6. Use Prisma Studio to inspect database

**You're still on the feature branch, so feel free to test everything before merging!**
