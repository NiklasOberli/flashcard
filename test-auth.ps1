# Authentication Test Suite
# Run: .\test-auth.ps1

$script:PassedTests = 0
$script:FailedTests = 0
$script:TestResults = @()

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
Write-Host "  FLASHCARD AUTHENTICATION TEST SUITE" -ForegroundColor Cyan
Write-Host "======================================================================"
$testEmail = "test$(Get-Random -Minimum 1000 -Maximum 9999)@example.com"
Write-Host "`nTest Email: $testEmail`n" -ForegroundColor Yellow
Test-Endpoint -Name "Server Health Check" -ExpectedResult "Server responds" -TestScript {
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:3001/" -Method Get -ErrorAction Stop
        return @{ Success = $true; Message = $response.message }
    } catch {
        return @{ Success = $false; Message = "Server not responding" }
    }
}

Test-Endpoint -Name "User Registration" -ExpectedResult "201 Created" -TestScript {
    try {
        $body = @{ email = $testEmail; password = "TestPass123" } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/register" -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
        $script:userId = $response.userId
        return @{ Success = $true; Message = "User created" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-Endpoint -Name "Duplicate Email" -ExpectedResult "409 Conflict" -TestScript {
    try {
        $body = @{ email = $testEmail; password = "TestPass123" } | ConvertTo-Json
        Invoke-RestMethod -Uri "http://localhost:3001/api/auth/register" -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
        return @{ Success = $false; Message = "Should reject duplicate" }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 409) {
            return @{ Success = $true; Message = "Duplicate rejected" }
        }
        return @{ Success = $false; Message = "Wrong status code" }
    }
}

Test-Endpoint -Name "Weak Password" -ExpectedResult "400 Bad Request" -TestScript {
    try {
        $body = @{ email = "weak@test.com"; password = "weak" } | ConvertTo-Json
        Invoke-RestMethod -Uri "http://localhost:3001/api/auth/register" -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
        return @{ Success = $false; Message = "Should reject weak password" }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 400) {
            return @{ Success = $true; Message = "Weak password rejected" }
        }
        return @{ Success = $false; Message = "Wrong status code" }
    }
}

Test-Endpoint -Name "Unverified Login Block" -ExpectedResult "403 Forbidden" -TestScript {
    try {
        $body = @{ email = $testEmail; password = "TestPass123" } | ConvertTo-Json
        Invoke-RestMethod -Uri "http://localhost:3001/api/auth/login" -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
        return @{ Success = $false; Message = "Should block unverified" }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 403) {
            return @{ Success = $true; Message = "Unverified blocked" }
        }
        return @{ Success = $false; Message = "Wrong status code" }
    }
}

Test-Endpoint -Name "Invalid Password" -ExpectedResult "401 Unauthorized" -TestScript {
    try {
        $body = @{ email = $testEmail; password = "WrongPass123" } | ConvertTo-Json
        Invoke-RestMethod -Uri "http://localhost:3001/api/auth/login" -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
        return @{ Success = $false; Message = "Should reject wrong password" }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 401) {
            return @{ Success = $true; Message = "Invalid password rejected" }
        }
        return @{ Success = $false; Message = "Wrong status code" }
    }
}
Write-Host "======================================================================"
Write-Host "  TEST RESULTS SUMMARY" -ForegroundColor Cyan
Write-Host "======================================================================"
$TotalTests = $script:PassedTests + $script:FailedTests
if ($script:FailedTests -eq 0) {
    Write-Host "`nALL TESTS PASSED! ($script:PassedTests/$TotalTests)" -ForegroundColor Green
} else {
    Write-Host "`nSOME TESTS FAILED! $script:PassedTests/$TotalTests passed" -ForegroundColor Red
}
Write-Host "`nResults:" -ForegroundColor Yellow
$script:TestResults | Format-Table -AutoSize
Write-Host "Test Email: $testEmail" -ForegroundColor Cyan
if ($script:userId) { Write-Host "User ID: $script:userId" -ForegroundColor Cyan }
Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "  - View database: cd backend ; npm run db:studio" -ForegroundColor White
Write-Host "  - See docs/testing.md for manual tests`n" -ForegroundColor White
if ($script:FailedTests -gt 0) { exit 1 } else { exit 0 }
