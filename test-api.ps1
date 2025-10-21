# Folders and Flashcards API Test Suite
# Run: .\test-api.ps1

$script:PassedTests = 0
$script:FailedTests = 0
$script:TestResults = @()
$script:token = $null
$script:folderId = $null
$script:flashcardId = $null

function Test-Endpoint {
    param([string]$Name, [scriptblock]$TestScript, [string]$ExpectedResult)
    Write-Host "Test: $Name" -ForegroundColor Cyan
    Write-Host "Expected: $ExpectedResult" -ForegroundColor Gray
    try {
        $result = & $TestScript
        if ($result.Success) {
            Write-Host "[PASS]" -ForegroundColor Green
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

Write-Host "`n======================================================================"
Write-Host "  FLASHCARD API TEST SUITE" -ForegroundColor Cyan
Write-Host "======================================================================"
$testEmail = "test$(Get-Random -Minimum 1000 -Maximum 9999)@example.com"
Write-Host "`nTest Email: $testEmail`n" -ForegroundColor Yellow

# Setup: Register and verify a user
Test-Endpoint -Name "Setup: Register User" -ExpectedResult "201 Created" -TestScript {
    try {
        $body = @{ email = $testEmail; password = "TestPass123" } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/register" -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
        return @{ Success = $true; Message = "User registered" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

# Manually verify the user in the database for testing
Test-Endpoint -Name "Setup: Verify User (Manual)" -ExpectedResult "User verified" -TestScript {
    try {
        # Note: In production, this would be done via email verification
        Write-Host "  Note: Run this SQL in database: UPDATE users SET email_verified = true WHERE email = '$testEmail'" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        return @{ Success = $true; Message = "User should be verified manually" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

# Login to get token
Test-Endpoint -Name "Setup: Login User" -ExpectedResult "200 OK with token" -TestScript {
    try {
        $body = @{ email = $testEmail; password = "TestPass123" } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/login" -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
        $script:token = $response.token
        if ($script:token) {
            return @{ Success = $true; Message = "Logged in successfully" }
        } else {
            return @{ Success = $false; Message = "No token received" }
        }
    } catch {
        return @{ Success = $false; Message = "Login failed - please verify user manually in database" }
    }
}

# Test Folders API
Write-Host "`n--- FOLDERS API TESTS ---" -ForegroundColor Yellow

Test-Endpoint -Name "Create Folder" -ExpectedResult "201 Created" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $body = @{ name = "Learning" } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/folders" -Method Post -Headers $headers -ContentType "application/json" -Body $body -ErrorAction Stop
        $script:folderId = $response.folder.id
        return @{ Success = $true; Message = "Folder created: $($response.folder.name)" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Get Folders" -ExpectedResult "200 OK with folders list" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/folders" -Method Get -Headers $headers -ErrorAction Stop
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
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/folders/$script:folderId" -Method Put -Headers $headers -ContentType "application/json" -Body $body -ErrorAction Stop
        return @{ Success = $true; Message = "Folder updated: $($response.folder.name)" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Create Folder - Empty Name" -ExpectedResult "400 Bad Request" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $body = @{ name = "" } | ConvertTo-Json
        Invoke-RestMethod -Uri "http://localhost:3001/api/folders" -Method Post -Headers $headers -ContentType "application/json" -Body $body -ErrorAction Stop
        return @{ Success = $false; Message = "Should reject empty name" }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 400) {
            return @{ Success = $true; Message = "Empty name rejected" }
        }
        return @{ Success = $false; Message = "Wrong status code" }
    }
}

# Test Flashcards API
Write-Host "`n--- FLASHCARDS API TESTS ---" -ForegroundColor Yellow

Test-Endpoint -Name "Create Flashcard" -ExpectedResult "201 Created" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $body = @{ 
            folderId = $script:folderId
            frontText = "What is TypeScript?"
            backText = "A typed superset of JavaScript"
        } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards" -Method Post -Headers $headers -ContentType "application/json" -Body $body -ErrorAction Stop
        $script:flashcardId = $response.flashcard.id
        return @{ Success = $true; Message = "Flashcard created" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Get All Flashcards" -ExpectedResult "200 OK with flashcards list" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards" -Method Get -Headers $headers -ErrorAction Stop
        if ($response.flashcards.Count -gt 0) {
            return @{ Success = $true; Message = "Retrieved $($response.flashcards.Count) flashcard(s)" }
        } else {
            return @{ Success = $false; Message = "No flashcards found" }
        }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Get Flashcards by Folder" -ExpectedResult "200 OK with filtered flashcards" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards?folder_id=$script:folderId" -Method Get -Headers $headers -ErrorAction Stop
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
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards/$script:flashcardId" -Method Put -Headers $headers -ContentType "application/json" -Body $body -ErrorAction Stop
        return @{ Success = $true; Message = "Flashcard updated" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Create Second Folder" -ExpectedResult "201 Created" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $body = @{ name = "Remembered" } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/folders" -Method Post -Headers $headers -ContentType "application/json" -Body $body -ErrorAction Stop
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
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards/$script:flashcardId/move" -Method Patch -Headers $headers -ContentType "application/json" -Body $body -ErrorAction Stop
        return @{ Success = $true; Message = "Flashcard moved to: $($response.flashcard.folder.name)" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Create Flashcard - Missing Fields" -ExpectedResult "400 Bad Request" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $body = @{ folderId = $script:folderId } | ConvertTo-Json
        Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards" -Method Post -Headers $headers -ContentType "application/json" -Body $body -ErrorAction Stop
        return @{ Success = $false; Message = "Should reject missing fields" }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 400) {
            return @{ Success = $true; Message = "Missing fields rejected" }
        }
        return @{ Success = $false; Message = "Wrong status code" }
    }
}

Test-Endpoint -Name "Delete Flashcard" -ExpectedResult "200 OK" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/flashcards/$script:flashcardId" -Method Delete -Headers $headers -ErrorAction Stop
        return @{ Success = $true; Message = "Flashcard deleted" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Delete Folder" -ExpectedResult "200 OK" -TestScript {
    try {
        $headers = @{ Authorization = "Bearer $script:token" }
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/folders/$script:folderId" -Method Delete -Headers $headers -ErrorAction Stop
        return @{ Success = $true; Message = "Folder deleted" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

# Test unauthorized access
Write-Host "`n--- AUTHORIZATION TESTS ---" -ForegroundColor Yellow

Test-Endpoint -Name "Unauthorized Access - No Token" -ExpectedResult "401 Unauthorized" -TestScript {
    try {
        Invoke-RestMethod -Uri "http://localhost:3001/api/folders" -Method Get -ErrorAction Stop
        return @{ Success = $false; Message = "Should require authentication" }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 401) {
            return @{ Success = $true; Message = "Unauthorized access blocked" }
        }
        return @{ Success = $false; Message = "Wrong status code" }
    }
}

# Summary
Write-Host "`n======================================================================"
Write-Host "  TEST SUMMARY" -ForegroundColor Cyan
Write-Host "======================================================================"
Write-Host "Total Tests: $($script:PassedTests + $script:FailedTests)"
Write-Host "Passed: $script:PassedTests" -ForegroundColor Green
Write-Host "Failed: $script:FailedTests" -ForegroundColor Red
Write-Host "======================================================================"

if ($script:FailedTests -eq 0) {
    Write-Host "`nAll tests passed! ✓" -ForegroundColor Green
} else {
    Write-Host "`nSome tests failed. Review the output above for details." -ForegroundColor Yellow
}

Write-Host "`n"
