# e-com
E-Commerce Backend Application built with Spring Boot, PostgreSQL, Docker, JPA/Hibernate, and REST APIs. Supports product, cart, order, and user management.

## Microservices

| Service        | Port | Database | Base path   |
|----------------|------|----------|-------------|
| config-service | 8888 | N/A      | Centralized configuration service |
| product-service| 8081 | product  | /api/products |
| user-service   | 8082 | userdb   | /api/users  |
| order-service  | 8083 | order    | /api/orders, /api/cart |

## Testing all microservices with PostgreSQL

1. **Start PostgreSQL** (creates databases `product`, `userdb`, `order` on first run):
   ```bash
   docker-compose up -d
   ```
   If you already had a running Postgres container without the init script, recreate it so the DBs are created:
   ```bash
   docker-compose down -v
   docker-compose up -d
   ```

2. **Start Config Service** (from project root, in a separate terminal):
   ```bash
   cd config/config && mvn spring-boot:run
   ```
   The config service should be started first as other services can optionally connect to it for centralized configuration.

3. **Start each microservice** (from project root, in separate terminals):
   ```bash
   cd product/product   && mvn spring-boot:run
   cd user/user         && mvn spring-boot:run
   cd order/order       && mvn spring-boot:run
   ```

4. **Run the test script** (PowerShell):
   ```powershell
   .\test-microservices.ps1
   ```
   The script calls Product, User, and Order APIs (GET/POST/PUT/DELETE and cart/order) and reports Pass/Fail.
