# Facade Service (FastAPI)

Acts as the central gateway for all user-facing interactions.

## Features
- OAuth2 token issuance & introspection
- Aggregates responses from inventory, orders, and reports microservices
- Routes traffic via Apigee proxies
- Enforces authentication, rate limiting, quotas, and spike arrest
- Common features: logging, metrics, error handling, input validation

## Local Development
```bash
uvicorn main:app --reload --port 8080
```

## Environment Variables
See `config/env.example` for required variables.
