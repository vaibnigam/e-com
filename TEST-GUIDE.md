# Testing Guide for All Microservices

## Prerequisites

1. **Databases must be running:**
   ```powershell
   docker-compose up -d
   ```

2. **Maven must be installed and in PATH**

## Step-by-Step Testing Instructions

### Step 1: Start Config Service (MUST BE FIRST)

Open a PowerShell terminal and run:
```powershell
cd config/config
mvn spring-boot:run
```

Wait until you see: `Started ConfigApplication in X.XXX seconds`

**Verify Config Service:**
- Open browser: http://localhost:8888/actuator/health
- Or test config endpoints:
  - http://localhost:8888/product-service/default
  - http://localhost:8888/user-service/default
  - http://localhost:8888/order-service/default

### Step 2: Start Product Service

Open a **NEW** PowerShell terminal:
```powershell
cd product/product
mvn spring-boot:run
```

Wait until you see: `Started ProductApplication in X.XXX seconds`

### Step 3: Start User Service

Open a **NEW** PowerShell terminal:
```powershell
cd user/user
mvn spring-boot:run
```

Wait until you see: `Started UserApplication in X.XXX seconds`

### Step 4: Start Order Service

Open a **NEW** PowerShell terminal:
```powershell
cd order/order
mvn spring-boot:run
```

Wait until you see: `Started OrderApplication in X.XXX seconds`

### Step 5: Run Tests

Once all services are running, open a **NEW** PowerShell terminal and run:
```powershell
.\test-all-services.ps1
```

## Quick Verification

You can manually verify each service:

1. **Config Service (8888):**
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:8888/actuator/health" -UseBasicParsing
   ```

2. **Product Service (8081):**
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:8081/api/products" -UseBasicParsing
   ```

3. **User Service (8082):**
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:8082/api/users" -UseBasicParsing
   ```

4. **Order Service (8083):**
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:8083/api/cart" -Headers @{"X-User-ID"="1"} -UseBasicParsing
   ```

## Troubleshooting

### Services fail to start

1. **Check if Config Service is running first** - Other services depend on it
2. **Check database connections:**
   - PostgreSQL: `docker ps` should show `postgres_container` running
   - MongoDB: `docker ps` should show `mongodb_container` running
3. **Check for port conflicts:**
   ```powershell
   netstat -ano | findstr ":8888 :8081 :8082 :8083"
   ```

### Config Service Connection Errors

If services show errors connecting to config server:
- Ensure config service is running on port 8888
- Check bootstrap.yml has correct URI: `http://localhost:8888`
- Services will retry 6 times before failing

### Configuration Issues

- All configurations are in: `config/config/src/main/resources/configurations/`
- Each service loads its config from config-server based on `spring.application.name` in bootstrap.yml
