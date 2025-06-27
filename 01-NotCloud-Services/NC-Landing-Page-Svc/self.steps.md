# Set variables
PROJECT_ID=gcp-apigee-playground-f2j3lk4j
REGION=asia-southeast1
REPO=apigee-demo-ar
IMAGE=nc-landing-page-svc

# Authenticate with Google Cloud
gcloud auth login
gcloud config set project $PROJECT_ID

# Enable required services (if not already enabled)
gcloud services enable artifactregistry.googleapis.com run.googleapis.com

# Create Artifact Registry repo if not already created
gcloud artifacts repositories create $REPO \
  --repository-format=docker \
  --location=$REGION

# Build the Docker image
cd "01-NotCloud-Services/NC-Landing-Page-Svc"
docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE:latest .

# Push the image to Artifact Registry
docker push $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE:latest

# Deploy to Cloud Run
gcloud run deploy $IMAGE \
  --image $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE:latest \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --timeout 60








