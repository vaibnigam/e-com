Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "COMPREHENSIVE MICROSERVICES TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost"
$productUrl = "${baseUrl}:8081/api/products"
$userUrl = "${baseUrl}:8082/api/users"
$orderUrl = "${baseUrl}:8083/api/orders"
$cartUrl = "${baseUrl}:8083/api/cart"

$testResults = @()

# Helper function to test endpoint
function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Url,
        [hashtable]$Headers = @{},
        [object]$Body = $null,
        [int]$ExpectedStatus = 200
    )
    
    Write-Host "Testing: $Name" -ForegroundColor Yellow
    Write-Host "  Method: $Method | URL: $Url" -ForegroundColor Gray
    
    try {
        $params = @{
            Uri = $Url
            Method = $Method
            Headers = $Headers
            TimeoutSec = 5
            ErrorAction = "Stop"
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
            $params.ContentType = "application/json"
        }
        
        $response = Invoke-RestMethod @params
        $statusCode = 200
        
        Write-Host "  SUCCESS - Status: $statusCode" -ForegroundColor Green
        if ($response) {
            Write-Host "  Response: $($response | ConvertTo-Json -Compress -Depth 3)" -ForegroundColor Gray
        }
        
        return @{ Success = $true; Response = $response; StatusCode = $statusCode }
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "  FAILED - Status: $statusCode" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        
        return @{ Success = $false; Error = $_.Exception.Message; StatusCode = $statusCode }
    }
    finally {
        Write-Host ""
    }
}

# ============================================
# 1. PRODUCT SERVICE TESTS
# ============================================
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "1. PRODUCT SERVICE (Port 8081)" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

# Get all products
$result = Test-Endpoint -Name "GET All Products" -Method "GET" -Url $productUrl
$testResults += $result

# Create a test product
$newProduct = @{
    name = "Test Laptop"
    description = "High-performance laptop for testing"
    price = 999.99
    stockQuantity = 50
    category = "Electronics"
    imageUrl = "https://example.com/laptop.jpg"
}
$result = Test-Endpoint -Name "POST Create Product" -Method "POST" -Url $productUrl -Body $newProduct -ExpectedStatus 201
$testResults += $result
$createdProduct = $result.Response

# Get products again to verify
$result = Test-Endpoint -Name "GET All Products (After Create)" -Method "GET" -Url $productUrl
$testResults += $result

# ============================================
# 2. USER SERVICE TESTS
# ============================================
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "2. USER SERVICE (Port 8082)" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

# Get all users
$result = Test-Endpoint -Name "GET All Users" -Method "GET" -Url $userUrl
$testResults += $result

# Create a test user
$newUser = @{
    firstName = "John"
    lastName = "Doe"
    email = "john.doe@example.com"
    phone = "1234567890"
    address = @{
        street = "123 Main Street"
        city = "New York"
        state = "NY"
        country = "USA"
        zipcode = "10001"
    }
}
$result = Test-Endpoint -Name "POST Create User" -Method "POST" -Url $userUrl -Body $newUser -ExpectedStatus 200
$testResults += $result
$createdUser = $result.Response

# Get users again to verify
$result = Test-Endpoint -Name "GET All Users (After Create)" -Method "GET" -Url $userUrl
$testResults += $result
$users = $result.Response

# Get user ID for cart tests
$userId = $null
if ($users -and $users.Count -gt 0) {
    $userId = $users[0].id
    Write-Host "Found User ID: $userId" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "WARNING: No user found. Cart tests may fail." -ForegroundColor Yellow
    Write-Host ""
    $userId = "1" # Fallback
}

# ============================================
# 3. CART SERVICE TESTS
# ============================================
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "3. CART SERVICE (Port 8083)" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

$cartHeaders = @{
    "X-User-ID" = $userId
    "Content-Type" = "application/json"
}

# Get cart (should be empty initially)
$result = Test-Endpoint -Name "GET Cart (Empty)" -Method "GET" -Url $cartUrl -Headers $cartHeaders
$testResults += $result

# Add product to cart
$cartItem = @{
    productId = "1"
    quantity = 2
}
$result = Test-Endpoint -Name "POST Add Product to Cart" -Method "POST" -Url $cartUrl -Headers $cartHeaders -Body $cartItem -ExpectedStatus 201
$testResults += $result

# Get cart again to verify item was added
$result = Test-Endpoint -Name "GET Cart (With Items)" -Method "GET" -Url $cartUrl -Headers $cartHeaders
$testResults += $result

# Add another product to cart
$cartItem2 = @{
    productId = "1"
    quantity = 1
}
$result = Test-Endpoint -Name "POST Add Same Product Again (Update Quantity)" -Method "POST" -Url $cartUrl -Headers $cartHeaders -Body $cartItem2 -ExpectedStatus 201
$testResults += $result

# Get cart to see updated quantity
$result = Test-Endpoint -Name "GET Cart (Updated Quantity)" -Method "GET" -Url $cartUrl -Headers $cartHeaders
$testResults += $result

# Remove item from cart
$result = Test-Endpoint -Name "DELETE Remove Item from Cart" -Method "DELETE" -Url "$cartUrl/items/1" -Headers $cartHeaders -ExpectedStatus 204
$testResults += $result

# Get cart to verify item was removed
$result = Test-Endpoint -Name "GET Cart (After Removal)" -Method "GET" -Url $cartUrl -Headers $cartHeaders
$testResults += $result

# ============================================
# 4. ORDER SERVICE TESTS
# ============================================
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "4. ORDER SERVICE (Port 8083)" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

$orderHeaders = @{
    "X-User-ID" = $userId
    "Content-Type" = "application/json"
}

# Create an order (requires items in cart)
# First, add items back to cart
$cartItem = @{
    productId = "1"
    quantity = 1
}
$result = Test-Endpoint -Name "POST Add Product to Cart (For Order)" -Method "POST" -Url $cartUrl -Headers $cartHeaders -Body $cartItem -ExpectedStatus 201
$testResults += $result

# Create order
$result = Test-Endpoint -Name "POST Create Order" -Method "POST" -Url $orderUrl -Headers $orderHeaders -ExpectedStatus 201
$testResults += $result

# ============================================
# TEST SUMMARY
# ============================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$totalTests = $testResults.Count
$passedTests = ($testResults | Where-Object { $_.Success -eq $true }).Count
$failedTests = $totalTests - $passedTests

Write-Host "Total Tests: $totalTests" -ForegroundColor White
Write-Host "Passed: $passedTests" -ForegroundColor Green
Write-Host "Failed: $failedTests" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($failedTests -eq 0) {
    Write-Host "All tests passed successfully!" -ForegroundColor Green
} else {
    Write-Host "Some tests failed. Check the output above for details." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
