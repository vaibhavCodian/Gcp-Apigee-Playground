#! /bin/bash
# deploy-cr.sh
# Deploy NotCloud Landing Page Service to Cloud Run
# Usage: bash deploy-cr.sh

# set -e

# ---- CONFIG ----
PROJECT_ID=peaceful-tide-466409-q7
REGION=asia-southeast1
REPO=notcloud-demo-ar
SERVICE_NAME=landing-page-svc # Name of the service to deploy
IMAGE_NAME=landing-page-svc # Image name in Artifact Registry
# ---- COLORS ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Authenticate and set project
if ! gcloud config get-value project | grep -q "$PROJECT_ID"; then
  echo -e "${YELLOW}Setting GCP project to $PROJECT_ID...${NC}"
  gcloud config set project $PROJECT_ID
else
  echo -e "${GREEN}Project already set to $PROJECT_ID.${NC}"
fi

gcloud auth configure-docker $REGION-docker.pkg.dev
gcloud services enable artifactregistry.googleapis.com run.googleapis.com
# Create Artifact Registry repo if not exists
if ! gcloud artifacts repositories describe $REPO --location=$REGION >/dev/null 2>&1; then
  echo -e "${YELLOW}Creating Artifact Registry repository $REPO...${NC}"
  gcloud artifacts repositories create $REPO --repository-format=docker --location=$REGION
else
  echo -e "${GREEN}Artifact Registry repository $REPO already exists.${NC}"
fi

# ---- BUILD, PUSH, DEPLOY ----

echo -e "\n=== Building Docker image for $SERVICE_NAME ==="
cd NC-Landing-Page-Svc

##############################################
# Build the image
##############################################

containerd build -t $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE_NAME:latest .
if [ $? -ne 0 ]; then
  echo -e "${RED}Error building Docker image for $SERVICE_NAME.${NC}"
  exit 1
fi
echo -e "${GREEN}Successfully built Docker image for $SERVICE_NAME.${NC}"

##############################################
# Push the image to Artifact Registry
##############################################

echo -e "\n=== Pushing Docker image to Artifact Registry ==="
containerd push $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE_NAME:latest
if [ $? -ne 0 ]; then
  echo -e "${RED}Error pushing Docker image to Artifact Registry.${NC}"
  exit 1
fi
echo -e "${GREEN}Successfully pushed Docker image to Artifact Registry.${NC}"

################################################
# Deploy to Cloud Run
################################################

echo -e "\n=== Deploying $SERVICE_NAME to Cloud Run ==="
gcloud run deploy $SERVICE_NAME \
  --image $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE_NAME:latest \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --timeout 60
if [ $? -ne 0 ]; then
  echo -e "${RED}Error deploying $SERVICE_NAME to Cloud Run.${NC}"
  exit 1
fi