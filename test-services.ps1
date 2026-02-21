Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Testing All Microservices" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# Test Product Service
Write-Host "=== Testing Product Service (Port 8081) ===" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/api/products" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✓ Product Service is UP" -ForegroundColor Green
    Write-Host "  Status Code: $($response.StatusCode)"
    Write-Host "  Response: $($response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)))"
} catch {
    Write-Host "✗ Product Service Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Check if service is running on port 8081" -ForegroundColor Yellow
}

Write-Host ""

# Test User Service
Write-Host "=== Testing User Service (Port 8082) ===" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082/api/users" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✓ User Service is UP" -ForegroundColor Green
    Write-Host "  Status Code: $($response.StatusCode)"
    Write-Host "  Response: $($response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)))"
} catch {
    Write-Host "✗ User Service Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Check if service is running on port 8082" -ForegroundColor Yellow
}

Write-Host ""

# Test Order Service
Write-Host "=== Testing Order Service (Port 8083) ===" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8083/api/orders" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✓ Order Service is UP" -ForegroundColor Green
    Write-Host "  Status Code: $($response.StatusCode)"
    Write-Host "  Response: $($response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)))"
} catch {
    Write-Host "✗ Order Service Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Check if service is running on port 8083" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Test Complete" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
