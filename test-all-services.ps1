# Test all e-commerce microservices including Config Service
# Prerequisites: PostgreSQL and MongoDB running (docker-compose up -d)

$ErrorActionPreference = "Stop"
$configUrl = "http://localhost:8888"
$productUrl = "http://localhost:8081"
$userUrl = "http://localhost:8082"
$orderUrl = "http://localhost:8083"

$passed = 0
$failed = 0

function Wait-ForService {
    param(
        [string]$Name,
        [string]$Url,
        [int]$MaxAttempts = 30,
        [int]$DelaySeconds = 2
    )
    Write-Host "Waiting for $Name to be ready..." -ForegroundColor Yellow
    for ($i = 1; $i -le $MaxAttempts; $i++) {
        try {
            $response = Invoke-WebRequest -Uri $Url -Method GET -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
            Write-Host "  [$Name] is ready!" -ForegroundColor Green
            return $true
        } catch {
            if ($i -eq $MaxAttempts) {
                Write-Host "  [$Name] failed to start after $($MaxAttempts * $DelaySeconds) seconds" -ForegroundColor Red
                return $false
            }
            Start-Sleep -Seconds $DelaySeconds
        }
    }
    return $false
}

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Url,
        [object]$Body = $null,
        [hashtable]$Headers = @{}
    )
    try {
        $params = @{
            Method = $Method
            Uri = $Url
            ContentType = "application/json"
            UseBasicParsing = $true
        }
        if ($Headers.Count -gt 0) { $params.Headers = $Headers }
        if ($Body) { $params.Body = ($Body | ConvertTo-Json -Depth 5) }
        $r = Invoke-WebRequest @params
        Write-Host "  [PASS] $Name" -ForegroundColor Green
        $script:passed++
        return $r
    } catch {
        Write-Host "  [FAIL] $Name - $($_.Exception.Message)" -ForegroundColor Red
        $script:failed++
        return $null
    }
}

Write-Host "`n=== Testing All Microservices (Config + Product + User + Order) ===" -ForegroundColor Cyan
Write-Host "Config: $configUrl | Product: $productUrl | User: $userUrl | Order: $orderUrl`n"

# --- Config Service (8888) ---
Write-Host "--- Config Service ---" -ForegroundColor Yellow
if (-not (Wait-ForService -Name "Config Service" -Url "$configUrl/actuator/health")) {
    Write-Host "Config Service is not running. Please start it first:" -ForegroundColor Red
    Write-Host "  cd config/config && mvn spring-boot:run" -ForegroundColor Yellow
    exit 1
}
Test-Endpoint -Name "GET /actuator/health" -Method GET -Url "$configUrl/actuator/health"
Test-Endpoint -Name "GET /product-service/default" -Method GET -Url "$configUrl/product-service/default"
Test-Endpoint -Name "GET /user-service/default" -Method GET -Url "$configUrl/user-service/default"
Test-Endpoint -Name "GET /order-service/default" -Method GET -Url "$configUrl/order-service/default"

# --- Product Service (8081) ---
Write-Host "`n--- Product Service ---" -ForegroundColor Yellow
if (-not (Wait-ForService -Name "Product Service" -Url "$productUrl/api/products")) {
    Write-Host "Product Service is not running. Please start it:" -ForegroundColor Red
    Write-Host "  cd product/product && mvn spring-boot:run" -ForegroundColor Yellow
    exit 1
}
$p1 = Test-Endpoint -Name "GET /api/products" -Method GET -Url "$productUrl/api/products"
$createProduct = Test-Endpoint -Name "POST /api/products" -Method POST -Url "$productUrl/api/products" -Body @{
    name = "Test Product"
    description = "Test description"
    price = 99.99
    stockQuantity = 10
    category = "Electronics"
    imageUrl = ""
}
$productId = $null
if ($createProduct -and $createProduct.Content) {
    $productId = ($createProduct.Content | ConvertFrom-Json).id
    Test-Endpoint -Name "GET /api/products/search?keyword=Test" -Method GET -Url "$productUrl/api/products/search?keyword=Test"
    if ($productId) {
        Test-Endpoint -Name "PUT /api/products/$productId" -Method PUT -Url "$productUrl/api/products/$productId" -Body @{
            name = "Test Product Updated"
            description = "Updated"
            price = 89.99
            stockQuantity = 5
            category = "Electronics"
            imageUrl = ""
        }
    }
}

# --- User Service (8082) ---
Write-Host "`n--- User Service ---" -ForegroundColor Yellow
if (-not (Wait-ForService -Name "User Service" -Url "$userUrl/api/users")) {
    Write-Host "User Service is not running. Please start it:" -ForegroundColor Red
    Write-Host "  cd user/user && mvn spring-boot:run" -ForegroundColor Yellow
    exit 1
}
Test-Endpoint -Name "GET /api/users" -Method GET -Url "$userUrl/api/users"
$createUser = Test-Endpoint -Name "POST /api/users" -Method POST -Url "$userUrl/api/users" -Body @{
    firstName = "Test"
    lastName = "User"
    email = "testuser@example.com"
    phone = "1234567890"
    address = @{
        street = "123 Main St"
        city = "City"
        state = "State"
        country = "Country"
        zipcode = "12345"
    }
}
$userId = "1"
Test-Endpoint -Name "GET /api/users/1" -Method GET -Url "$userUrl/api/users/1"
Test-Endpoint -Name "PUT /api/users/1" -Method PUT -Url "$userUrl/api/users/1" -Body @{
    firstName = "TestUpdated"
    lastName = "User"
    email = "testuser@example.com"
    phone = "1234567890"
    address = @{
        street = "123 Main St"
        city = "City"
        state = "State"
        country = "Country"
        zipcode = "12345"
    }
}

# --- Order Service (8083) - Cart & Order ---
Write-Host "`n--- Order Service (Cart) ---" -ForegroundColor Yellow
if (-not (Wait-ForService -Name "Order Service" -Url "$orderUrl/api/cart")) {
    Write-Host "Order Service is not running. Please start it:" -ForegroundColor Red
    Write-Host "  cd order/order && mvn spring-boot:run" -ForegroundColor Yellow
    exit 1
}
$cartHeaders = @{ "X-User-ID" = $userId }
if ($productId) {
    Test-Endpoint -Name "POST /api/cart" -Method POST -Url "$orderUrl/api/cart" -Headers $cartHeaders -Body @{
        productId = "$productId"
        quantity = 2
    }
}
Test-Endpoint -Name "GET /api/cart" -Method GET -Url "$orderUrl/api/cart" -Headers $cartHeaders
Test-Endpoint -Name "POST /api/orders" -Method POST -Url "$orderUrl/api/orders" -Headers $cartHeaders
if ($productId) {
    Test-Endpoint -Name "DELETE /api/cart/items/$productId" -Method DELETE -Url "$orderUrl/api/cart/items/$productId" -Headers $cartHeaders
}

# --- Summary ---
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Passed: $passed | Failed: $failed"
if ($failed -gt 0) { exit 1 }
