#!/bin/bash
# Walkthrough: Deploy all NotCloud Inc. microservices to Cloud Run in one go
# Usage: bash deploy_all.sh

set -e

# ---- CONFIG ----
PROJECT_ID=gcp-apigee-playground-f2j3lk4j
REGION=asia-southeast1
REPO=notcloud-demo-ar

# Service list (directory name, image name)
SERVICES=(
  "facade-service facade-service"
  "inventory-service inventory-service"
  "orders-service orders-service"
  "reports-service reports-service"
  "cpp-service cpp-service"
  "go-service go-service"
  # Add legacy-spring-service if Dockerfile is present
)

# Authenticate and set project
if ! gcloud config get-value project | grep -q "$PROJECT_ID"; then
  gcloud config set project $PROJECT_ID
fi

gcloud auth configure-docker $REGION-docker.pkg.dev

gcloud services enable artifactregistry.googleapis.com run.googleapis.com

# Create Artifact Registry repo if not exists
if ! gcloud artifacts repositories describe $REPO --location=$REGION >/dev/null 2>&1; then
  gcloud artifacts repositories create $REPO --repository-format=docker --location=$REGION
fi

# ---- BUILD, PUSH, DEPLOY ----
for entry in "${SERVICES[@]}"; do
  set -- $entry
  DIR=$1
  IMAGE=$2
  echo "\n=== Building $DIR ==="
  cd $DIR
  docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE:latest .
  docker push $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE:latest
  echo "\n=== Deploying $IMAGE to Cloud Run ==="
  gcloud run deploy $IMAGE \
    --image $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE:latest \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --port 8080 \
    --memory 512Mi \
    --timeout 60
  cd ..
done

echo "\nAll services deployed!"
