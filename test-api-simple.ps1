# Simple API Test Script
# This script tests the folders and flashcards API endpoints

Write-Host "`n======================================================================"
Write-Host "  FLASHCARD API TEST" -ForegroundColor Cyan
Write-Host "======================================================================"

# Generate test email
$testEmail = "apitest$(Get-Random -Minimum 1000 -Maximum 9999)@example.com"
Write-Host "`nTest Email: $testEmail" -ForegroundColor Yellow

# Step 1: Register user
Write-Host "`n1. Registering user..." -ForegroundColor Cyan
try {
    $body = @{ email = $testEmail; password = "TestPass123" } | ConvertTo-Json
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/register" -Method Post -ContentType "application/json" -Body $body
    Write-Host "   [SUCCESS] User registered" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Verify user in database
Write-Host "`n2. Verifying user in database..." -ForegroundColor Cyan
Write-Host "   Run this command in a separate terminal:" -ForegroundColor Yellow
Write-Host "   docker exec flashcard-db psql -U flashcard_user -d flashcard_db -c `"UPDATE users SET email_verified = true WHERE email = '$testEmail';`"" -ForegroundColor White
Write-Host "`n   Press any key when done..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

# Step 3: Login
Write-Host "`n3. Logging in..." -ForegroundColor Cyan
try {
    $body = @{ email = $testEmail; password = "TestPass123" } | ConvertTo-Json
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/login" -Method Post -ContentType "application/json" -Body $body
    $token = $loginResponse.token
    $headers = @{ Authorization = "Bearer $token" }
    Write-Host "   [SUCCESS] Logged in" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Make sure you verified the user in the database!" -ForegroundColor Yellow
    exit 1
}

# Step 4: Create folder
Write-Host "`n4. Creating folder..." -ForegroundColor Cyan
try {
    $body = @{ name = "Learning" } | ConvertTo-Json
    $folderResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/folders" -Method Post -Headers $headers -ContentType "application/json" -Body $body
    $folderId = $folderResponse.folder.id
    Write-Host "   [SUCCESS] Folder created: $($folderResponse.folder.name) (ID: $folderId)" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 5: Get folders
Write-Host "`n5. Getting folders..." -ForegroundColor Cyan
try {
    $foldersResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/folders" -Method Get -Headers $headers
    Write-Host "   [SUCCESS] Retrieved $($foldersResponse.folders.Count) folder(s)" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] $($_.Exception.Message)" -ForegroundColor Red
}

# Step 6: Update folder
Write-Host "`n6. Updating folder..." -ForegroundColor Cyan
try {
    $body = @{ name = "Learning - Updated" } | ConvertTo-Json
    $updateFolderResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/folders/$folderId" -Method Put -Headers $headers -ContentType "application/json" -Body $body
    Write-Host "   [SUCCESS] Folder updated: $($updateFolderResponse.folder.name)" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] $($_.Exception.Message)" -ForegroundColor Red
}

# Step 7: Create flashcard
Write-Host "`n7. Creating flashcard..." -ForegroundColor Cyan
try {
    $body = @{ 
        folderId = $folderId
        frontText = "What is TypeScript?"
        backText = "A typed superset of JavaScript"
    } | ConvertTo-Json
    $flashcardResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards" -Method Post -Headers $headers -ContentType "application/json" -Body $body
    $flashcardId = $flashcardResponse.flashcard.id
    Write-Host "   [SUCCESS] Flashcard created (ID: $flashcardId)" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 8: Get all flashcards
Write-Host "`n8. Getting all flashcards..." -ForegroundColor Cyan
try {
    $flashcardsResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards" -Method Get -Headers $headers
    Write-Host "   [SUCCESS] Retrieved $($flashcardsResponse.flashcards.Count) flashcard(s)" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] $($_.Exception.Message)" -ForegroundColor Red
}

# Step 9: Get flashcards by folder
Write-Host "`n9. Getting flashcards by folder..." -ForegroundColor Cyan
try {
    $flashcardsByFolderResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards?folder_id=$folderId" -Method Get -Headers $headers
    Write-Host "   [SUCCESS] Retrieved $($flashcardsByFolderResponse.flashcards.Count) flashcard(s) from folder" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] $($_.Exception.Message)" -ForegroundColor Red
}

# Step 10: Update flashcard
Write-Host "`n10. Updating flashcard..." -ForegroundColor Cyan
try {
    $body = @{ 
        frontText = "What is TypeScript? (Updated)"
        backText = "A typed superset of JavaScript that compiles to plain JavaScript"
    } | ConvertTo-Json
    $updateFlashcardResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards/$flashcardId" -Method Put -Headers $headers -ContentType "application/json" -Body $body
    Write-Host "   [SUCCESS] Flashcard updated" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] $($_.Exception.Message)" -ForegroundColor Red
}

# Step 11: Create second folder
Write-Host "`n11. Creating second folder..." -ForegroundColor Cyan
try {
    $body = @{ name = "Remembered" } | ConvertTo-Json
    $folder2Response = Invoke-RestMethod -Uri "http://localhost:3001/api/folders" -Method Post -Headers $headers -ContentType "application/json" -Body $body
    $folder2Id = $folder2Response.folder.id
    Write-Host "   [SUCCESS] Second folder created: $($folder2Response.folder.name) (ID: $folder2Id)" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] $($_.Exception.Message)" -ForegroundColor Red
}

# Step 12: Move flashcard
Write-Host "`n12. Moving flashcard to second folder..." -ForegroundColor Cyan
try {
    $body = @{ folderId = $folder2Id } | ConvertTo-Json
    $moveResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards/$flashcardId/move" -Method Patch -Headers $headers -ContentType "application/json" -Body $body
    Write-Host "   [SUCCESS] Flashcard moved to: $($moveResponse.flashcard.folder.name)" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] $($_.Exception.Message)" -ForegroundColor Red
}

# Step 13: Delete flashcard
Write-Host "`n13. Deleting flashcard..." -ForegroundColor Cyan
try {
    Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards/$flashcardId" -Method Delete -Headers $headers
    Write-Host "   [SUCCESS] Flashcard deleted" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] $($_.Exception.Message)" -ForegroundColor Red
}

# Step 14: Delete folders
Write-Host "`n14. Deleting folders..." -ForegroundColor Cyan
try {
    Invoke-RestMethod -Uri "http://localhost:3001/api/folders/$folderId" -Method Delete -Headers $headers
    Write-Host "   [SUCCESS] First folder deleted" -ForegroundColor Green
    Invoke-RestMethod -Uri "http://localhost:3001/api/folders/$folder2Id" -Method Delete -Headers $headers
    Write-Host "   [SUCCESS] Second folder deleted" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] $($_.Exception.Message)" -ForegroundColor Red
}

# Step 15: Test unauthorized access
Write-Host "`n15. Testing unauthorized access..." -ForegroundColor Cyan
try {
    Invoke-RestMethod -Uri "http://localhost:3001/api/folders" -Method Get -ErrorAction Stop
    Write-Host "   [FAIL] Should have been blocked" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "   [SUCCESS] Unauthorized access properly blocked" -ForegroundColor Green
    } else {
        Write-Host "   [ERROR] Wrong status code" -ForegroundColor Red
    }
}

Write-Host "`n======================================================================"
Write-Host "  ALL TESTS COMPLETED!" -ForegroundColor Green
Write-Host "======================================================================"
Write-Host ""
