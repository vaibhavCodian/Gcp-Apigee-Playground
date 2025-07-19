#!/bin/bash
# 2-deploy-apgiee-proxy.sh
# Deploy NotCloud Landing Page Service to Apigee Proxy Using API Request
# This script assumes you have already deployed the service to Cloud Run

# Usage: bash 2-deploy-apgiee-proxy.sh

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

# Get Access Token
ACCESS_TOKEN=$(gcloud auth print-access-token)


# STEP 1: Check if Apigee Proxy Exists
echo -e "\n=== Checking if Apigee Proxy exists ==="
APIGEE_PROXY_NAME="landing-page-proxy"
APIGEE_PROXY_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" \
# Deploy Apigee Proxy
echo -e "\n=== Deploying Apigee Proxy ==="
https://apigee.googleapis.com/v1/projects/$PROJECT_ID/locations/$REGION/apis/${APIGEE_PROXY_NAME} | grep -q "200")
if [ $? -ne 0 ]; then
  echo -e "\n=== Deploying Apigee Proxy ==="
    curl -X POST \
    -H "Authorization: Bearer $ACCESS_TOKEN"