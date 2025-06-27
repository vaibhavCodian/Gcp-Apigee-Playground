# Apigee Playground Backend

A dynamic FastAPI application to test all Apigee use cases in a single Cloud Run deployment.

## Features
- JWT/OAuth2 protected endpoints
- Rate limiting (demo)
- Preflow/Postflow simulation
- Basic proxy echo
- Dynamic headers and response manipulation
- Ready for Apigee, API Gateway, or direct testing

## Endpoints
- `/hello` – Simple hello world
- `/secure` – JWT/OAuth2 protected
- `/ratelimit` – Simulated rate-limited endpoint
- `/prepost` – Simulates preflow/postflow logic
- `/echo` – Echoes request headers/body

## Usage
- Deploy to Cloud Run or any container platform
- Use as a backend for Apigee proxy examples

---
See root `README.md` for architecture and integration details.
