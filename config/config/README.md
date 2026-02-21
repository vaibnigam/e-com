# Config Service

Centralized configuration service for E-Commerce microservices using Spring Cloud Config Server.

## Overview

The Config Service provides centralized configuration management for all microservices:
- **product-service** (port 8081)
- **user-service** (port 8082)
- **order-service** (port 8083)

## Port

- **Config Service**: 8888

## Running the Config Service

From the project root:

```bash
cd config/config
mvn spring-boot:run
```

## Configuration Files

Configuration files for each service are stored in:
- `src/main/resources/configurations/product-service.yml`
- `src/main/resources/configurations/user-service.yml`
- `src/main/resources/configurations/order-service.yml`

## Accessing Configurations

Once the config service is running, you can access configurations via REST API:

- Product Service Config: `http://localhost:8888/product-service/default`
- User Service Config: `http://localhost:8888/user-service/default`
- Order Service Config: `http://localhost:8888/order-service/default`

## Microservice Configuration

All microservices (product, user, order) are already configured to use the config server:

### Each service has:
1. **bootstrap.yml** - Contains minimal bootstrap configuration:
   - Service name (used to identify which config to fetch)
   - Config server URI and connection settings
   - Retry logic for config server connection

2. **application.yml** - Contains only comments and minimal overrides (if needed)
   - Most configurations are loaded from the config server
   - Only environment-specific overrides should be added here

### Configuration Flow:
1. Service starts and reads `bootstrap.yml`
2. Connects to config server using service name
3. Fetches configuration from `config/config/src/main/resources/configurations/{service-name}.yml`
4. Merges with `application.yml` (config server takes precedence)

### Important Notes:
- **Config server must be running before starting other services**
- Services will retry connecting to config server (up to 6 attempts)
- If config server is unavailable, services will fail to start (fail-fast: true)

## Dependencies

- Spring Boot 4.0.2
- Spring Cloud Config Server 2024.0.0
- Spring Boot Actuator (for health checks and monitoring)
