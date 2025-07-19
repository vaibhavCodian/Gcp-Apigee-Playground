#!/bin/bash
# 1-update-cr.sh
# Update NotCloud Landing Page Service to Cloud Run To Allow unauthenticated access only
# Usage: bash 1-update-cr.sh

# set -e # Uncomment to exit on error
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

# Update Cloud Run Service To Remove Unauthenticated Access
echo -e "\n=== Updating Cloud Run service $SERVICE_NAME to allow unauthenticated access ==="
gcloud run services update $SERVICE_NAME \
  --image $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE_NAME:latest \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --timeout 60
if [ $? -ne 0 ]; then
  echo -e "${RED}Error updating Cloud Run service $SERVICE_NAME.${NC}"
  exit 1
fi
echo -e "${GREEN}Successfully updated Cloud Run service $SERVICE_NAME.${NC}"


# Optional: Create Apigee Service Account for Cloud Run
echo -e "\n=== Creating Apigee Service Account for Cloud Run ==="
gcloud iam service-accounts create apigee-cloud-run-sa \
  --display-name "Apigee Cloud Run Service Account"
if [ $? -ne 0 ]; then
  echo -e "${RED}Error creating Apigee Service Account.${NC}"
  exit 1
fi
echo -e "${GREEN}Successfully created Apigee Service Account.${NC}"



# Grant roles to the service account
echo -e "\n=== Granting roles to Apigee Service Account ==="
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member "serviceAccount:apigee-cloud-run-sa@$PROJECT_ID.iam.googleapis.com" \
  --role "roles/run.invoker"
if [ $? -ne 0 ]; then
  echo -e "${RED}Error granting roles to Apigee Service Account.${NC}"
  exit 1
fi
echo -e "${GREEN}Successfully granted roles to Apigee Service Account.${NC}"

echo -e "\nAll services updated!"