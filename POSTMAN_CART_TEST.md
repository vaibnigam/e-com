# Postman Test Guide: Add Product to Cart

## Endpoint Information

**URL:** `http://localhost:8083/api/cart`  
**Method:** `POST`  
**Service:** Order Service (Port 8083)

## Step-by-Step Postman Setup

### 1. Create New Request
- Click **New** → **HTTP Request**
- Name it: "Add Product to Cart"

### 2. Configure Request
- **Method:** Select `POST` from dropdown
- **URL:** Enter `http://localhost:8083/api/cart`

### 3. Add Headers
Go to **Headers** tab and add:

| Key | Value |
|-----|-------|
| `X-User-ID` | `1` (or your actual user ID) |
| `Content-Type` | `application/json` |

### 4. Add Request Body
Go to **Body** tab:
- Select **raw**
- Choose **JSON** from dropdown
- Enter the following JSON:

```json
{
  "productId": "1",
  "quantity": 2
}
```

### 5. Send Request
Click **Send** button

## Expected Responses

### Success Response (201 Created)
- **Status:** `201 Created`
- **Body:** Empty (or success message)

### Error Response (400 Bad Request)
- **Status:** `400 Bad Request`
- **Body:** `"Product Out of Stock or User not found or Product not found"`

## Example Test Scenarios

### Scenario 1: Add Product to Cart
```json
{
  "productId": "1",
  "quantity": 2
}
```
**Headers:**
- `X-User-ID`: `1`

### Scenario 2: Add Different Product
```json
{
  "productId": "2",
  "quantity": 1
}
```
**Headers:**
- `X-User-ID`: `1`

### Scenario 3: Increase Quantity (Same Product)
If you add the same product again, it will update the quantity:
```json
{
  "productId": "1",
  "quantity": 3
}
```
**Headers:**
- `X-User-ID`: `1`

## Related Endpoints

### Get Cart Items
- **Method:** `GET`
- **URL:** `http://localhost:8083/api/cart`
- **Headers:** `X-User-ID: 1`
- **Response:** List of cart items

### Remove Item from Cart
- **Method:** `DELETE`
- **URL:** `http://localhost:8083/api/cart/items/{productId}`
- **Example:** `http://localhost:8083/api/cart/items/1`
- **Headers:** `X-User-ID: 1`

## Prerequisites

1. **Order Service** must be running on port 8083
2. **User ID** must exist (check User Service at port 8082)
3. **Product ID** must exist (check Product Service at port 8081)

## Quick Test Commands (PowerShell)

```powershell
# Add product to cart
$headers = @{
    "X-User-ID" = "1"
    "Content-Type" = "application/json"
}
$body = @{
    productId = "1"
    quantity = 2
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8083/api/cart" -Method POST -Headers $headers -Body $body

# Get cart items
Invoke-RestMethod -Uri "http://localhost:8083/api/cart" -Method GET -Headers @{"X-User-ID" = "1"}
```
