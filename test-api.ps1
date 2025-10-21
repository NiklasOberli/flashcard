# Flashcard API Test Suite
# Comprehensive tests for folders and flashcards API endpoints

$script:PassedTests = 0
$script:FailedTests = 0
$script:TestResults = @()
$script:token = $null
$script:folderId = $null
$script:secondFolderId = $null
$script:flashcardId = $null

function Test-Endpoint {
    param([string]$Name, [scriptblock]$TestScript, [string]$ExpectedResult)
    Write-Host "Test: $Name" -ForegroundColor Cyan
    try {
        $result = & $TestScript
        if ($result.Success) {
            Write-Host "[PASS] $($result.Message)" -ForegroundColor Green
            $script:PassedTests++
            $script:TestResults += [PSCustomObject]@{Test=$Name;Status="PASS";Message=$result.Message}
        } else {
            Write-Host "[FAIL] $($result.Message)" -ForegroundColor Red
            $script:FailedTests++
            $script:TestResults += [PSCustomObject]@{Test=$Name;Status="FAIL";Message=$result.Message}
        }
    } catch {
        Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
        $script:FailedTests++
        $script:TestResults += [PSCustomObject]@{Test=$Name;Status="ERROR";Message=$_.Exception.Message}
    }
    Write-Host ""
}

Write-Host "
======================================================================"
Write-Host "  FLASHCARD API TEST SUITE" -ForegroundColor Cyan
Write-Host "======================================================================"

# Check if database is running
Write-Host "
Checking PostgreSQL database..." -ForegroundColor Cyan
try {
    $dockerPs = docker ps --filter "name=flashcard-db" --format "{{.Names}}"
    if ($dockerPs -ne "flashcard-db") {
        Write-Host "[WARNING] PostgreSQL container is not running." -ForegroundColor Yellow
        Write-Host "Please start it with: docker-compose up -d" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "[SUCCESS] Database is running" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Could not check Docker status. Make sure PostgreSQL is running." -ForegroundColor Yellow
}

# Generate test email
$testEmail = "apitest$(Get-Random -Minimum 1000 -Maximum 9999)@example.com"
Write-Host "
Test Email: $testEmail
" -ForegroundColor Yellow

Write-Host "--- AUTHENTICATION SETUP ---
" -ForegroundColor Yellow

Test-Endpoint -Name "Register Test User" -ExpectedResult "201 Created" -TestScript {
    try {
        $body = @{ email = $testEmail; password = "TestPass123" } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/register" `
            -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
        return @{ Success = $true; Message = "User registered successfully" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Verify User in Database" -ExpectedResult "User verified" -TestScript {
    try {
        $cmd = "UPDATE users SET email_verified = true WHERE email = '$testEmail';"
        docker exec flashcard-db psql -U flashcard_user -d flashcard_db -c $cmd | Out-Null
        return @{ Success = $true; Message = "User verified in database" }
    } catch {
        return @{ Success = $false; Message = "Failed to verify user: $($_.Exception.Message)" }
    }
}

Test-Endpoint -Name "Login Test User" -ExpectedResult "200 OK with token" -TestScript {
    try {
        $body = @{ email = $testEmail; password = "TestPass123" } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/login" `
            -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
        $script:token = $response.token
        if ($script:token) {
            return @{ Success = $true; Message = "Logged in successfully" }
        } else {
            return @{ Success = $false; Message = "No token received" }
        }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Write-Host "--- FOLDERS API TESTS ---
" -ForegroundColor Yellow

Test-Endpoint -Name "Create Folder" -ExpectedResult "201 Created" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $body = @{ name = "Learning" } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/folders" `
            -Method Post -Headers $headers -ContentType "application/json" -Body $body -ErrorAction Stop
        $script:folderId = $response.folder.id
        return @{ Success = $true; Message = "Folder created: $($response.folder.name)" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Get All Folders" -ExpectedResult "200 OK" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/folders" `
            -Method Get -Headers $headers -ErrorAction Stop
        if ($response.folders.Count -gt 0) {
            return @{ Success = $true; Message = "Retrieved $($response.folders.Count) folder(s)" }
        } else {
            return @{ Success = $false; Message = "No folders found" }
        }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Update Folder" -ExpectedResult "200 OK" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $body = @{ name = "Learning - Updated" } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/folders/$script:folderId" `
            -Method Put -Headers $headers -ContentType "application/json" -Body $body -ErrorAction Stop
        return @{ Success = $true; Message = "Folder updated: $($response.folder.name)" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Create Folder - Invalid Name" -ExpectedResult "400 Bad Request" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $body = @{ name = "" } | ConvertTo-Json
        Invoke-RestMethod -Uri "http://localhost:3001/api/folders" `
            -Method Post -Headers $headers -ContentType "application/json" -Body $body -ErrorAction Stop
        return @{ Success = $false; Message = "Should reject empty folder name" }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 400) {
            return @{ Success = $true; Message = "Empty folder name properly rejected" }
        }
        return @{ Success = $false; Message = "Wrong status code" }
    }
}

Write-Host "--- FLASHCARDS API TESTS ---
" -ForegroundColor Yellow

Test-Endpoint -Name "Create Flashcard" -ExpectedResult "201 Created" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $body = @{ 
            folderId = $script:folderId
            frontText = "What is TypeScript?"
            backText = "A typed superset of JavaScript"
        } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards" `
            -Method Post -Headers $headers -ContentType "application/json" -Body $body -ErrorAction Stop
        $script:flashcardId = $response.flashcard.id
        return @{ Success = $true; Message = "Flashcard created" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Get All Flashcards" -ExpectedResult "200 OK" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards" `
            -Method Get -Headers $headers -ErrorAction Stop
        if ($response.flashcards.Count -gt 0) {
            return @{ Success = $true; Message = "Retrieved $($response.flashcards.Count) flashcard(s)" }
        } else {
            return @{ Success = $false; Message = "No flashcards found" }
        }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Get Flashcards by Folder" -ExpectedResult "200 OK" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards?folder_id=$script:folderId" `
            -Method Get -Headers $headers -ErrorAction Stop
        if ($response.flashcards.Count -gt 0) {
            return @{ Success = $true; Message = "Retrieved $($response.flashcards.Count) flashcard(s) from folder" }
        } else {
            return @{ Success = $false; Message = "No flashcards found in folder" }
        }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Update Flashcard" -ExpectedResult "200 OK" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $body = @{ 
            frontText = "What is TypeScript? (Updated)"
            backText = "A typed superset of JavaScript that compiles to plain JavaScript"
        } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards/$script:flashcardId" `
            -Method Put -Headers $headers -ContentType "application/json" -Body $body -ErrorAction Stop
        return @{ Success = $true; Message = "Flashcard updated successfully" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Create Second Folder" -ExpectedResult "201 Created" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $body = @{ name = "Remembered" } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/folders" `
            -Method Post -Headers $headers -ContentType "application/json" -Body $body -ErrorAction Stop
        $script:secondFolderId = $response.folder.id
        return @{ Success = $true; Message = "Second folder created" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Move Flashcard to Another Folder" -ExpectedResult "200 OK" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $body = @{ folderId = $script:secondFolderId } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards/$script:flashcardId/move" `
            -Method Patch -Headers $headers -ContentType "application/json" -Body $body -ErrorAction Stop
        return @{ Success = $true; Message = "Flashcard moved to: $($response.flashcard.folder.name)" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Create Flashcard - Missing Fields" -ExpectedResult "400 Bad Request" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $body = @{ folderId = $script:folderId } | ConvertTo-Json
        Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards" `
            -Method Post -Headers $headers -ContentType "application/json" -Body $body -ErrorAction Stop
        return @{ Success = $false; Message = "Should reject flashcard with missing fields" }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 400) {
            return @{ Success = $true; Message = "Missing fields properly rejected" }
        }
        return @{ Success = $false; Message = "Wrong status code" }
    }
}

Test-Endpoint -Name "Delete Flashcard" -ExpectedResult "200 OK" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards/$script:flashcardId" `
            -Method Delete -Headers $headers -ErrorAction Stop
        return @{ Success = $true; Message = "Flashcard deleted successfully" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Delete First Folder" -ExpectedResult "200 OK" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards/$script:folderId" `
            -Method Delete -Headers $headers -ErrorAction Stop
        return @{ Success = $true; Message = "First folder deleted successfully" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Delete Second Folder" -ExpectedResult "200 OK" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        Invoke-RestMethod -Uri "http://localhost:3001/api/folders/$script:secondFolderId" `
            -Method Delete -Headers $headers -ErrorAction Stop
        return @{ Success = $true; Message = "Second folder deleted successfully" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Write-Host "--- AUTHORIZATION TESTS ---
" -ForegroundColor Yellow

Test-Endpoint -Name "Unauthorized Access - No Token" -ExpectedResult "401 Unauthorized" -TestScript {
    try {
        Invoke-RestMethod -Uri "http://localhost:3001/api/folders" -Method Get -ErrorAction Stop
        return @{ Success = $false; Message = "Should require authentication" }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 401) {
            return @{ Success = $true; Message = "Unauthorized access properly blocked" }
        }
        return @{ Success = $false; Message = "Wrong status code" }
    }
}

Write-Host "
======================================================================"
Write-Host "  TEST SUMMARY" -ForegroundColor Cyan
Write-Host "======================================================================"

$totalTests = $script:PassedTests + $script:FailedTests
Write-Host "Total Tests: $totalTests"
Write-Host "Passed: $script:PassedTests" -ForegroundColor Green
Write-Host "Failed: $script:FailedTests" -ForegroundColor Red
Write-Host "======================================================================"

if ($script:FailedTests -eq 0) {
    Write-Host "
 ALL TESTS PASSED!" -ForegroundColor Green
} else {
    Write-Host "
 SOME TESTS FAILED" -ForegroundColor Red
    Write-Host "
Failed Tests:" -ForegroundColor Yellow
    $script:TestResults | Where-Object { $_.Status -ne "PASS" } | ForEach-Object {
        Write-Host "  - $($_.Test): $($_.Message)" -ForegroundColor Red
    }
}

Write-Host ""
