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
PROXY_NAME=landing-page-proxy   # Name of the Apigee Proxy
SERVICE_NAME=landing-page-svc   # Name of the service to deploy
IMAGE_NAME=landing-page-svc     # Image name in Artifact Registry
ENVIROMENT=eval-env             # Apigee Environment Name
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
PROXY_CHECK =$(curl -s -o /dev/null -w "%{http_code}" \
    -H Authorization: Bearer $ACCESS_TOKEN \
    https://apigee.googleapis.com/v1/organizations/$PROJECT_ID/apis/$PROXY_NAME \)


# STEP 2: Handle Existing Deployment
if [ "$PROXY_CHECK" -eq 200 ]; then
  echo -e "${YELLOW}Apigee Proxy already exists. Checking for existing deployment...${NC}"
  DEPLOYMENT_CHECK=$(curl -s -o /dev/null -w "%{http_code}" \
    -H Authorization: Bearer $ACCESS_TOKEN \
    "https://apigee.googleapis.com/v1/organizations/$PROJECT_ID/environments/$ENVIROMENT/apis/$PROXY_NAME/deployments")

    if [ "$DEPLOYMENT_CHECK" -eq 200 ]; then
      echo -e "${GREEN}Apigee Proxy is already deployed in the environment $ENVIROMENT.${NC}"
      CURRENT_REV=$(ech)
      exit 0
    else
      echo -e "${YELLOW}Apigee Proxy exists but not deployed. Proceeding with deployment...${NC}"
    fi