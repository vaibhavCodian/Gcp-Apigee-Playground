# NGINX Example (Full Stack/FastAPI)

This folder contains an example of using NGINX as a reverse proxy for a FastAPI or full stack application. Useful for demonstrating custom routing, static file serving, and integration with Apigee.

## Features
- NGINX reverse proxy setup
- FastAPI or full stack backend
- Example deployment and configuration

## Usage
1. Build and run the NGINX + app container.
2. Deploy to Cloud Run or GKE as needed.
3. (Optional) Expose via Apigee proxy for API management features.

## Apigee Proxy
This example does not require a dedicated Apigee proxy configuration by default, but can be used as a backend for other Apigee proxy examples.

## Setup
1. Build the Docker image:
   ```bash
   docker build -t gcr.io/<PROJECT_ID>/nginx-example:latest .
   ```
2. Deploy to Cloud Run:
   ```bash
   gcloud run deploy nginx-example \
     --image gcr.io/<PROJECT_ID>/nginx-example:latest \
     --platform managed \
     --region <REGION> \
     --allow-unauthenticated
   ```
