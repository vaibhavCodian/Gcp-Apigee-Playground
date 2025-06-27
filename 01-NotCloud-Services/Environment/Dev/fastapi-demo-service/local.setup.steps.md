2. Build and Push the Docker Image to Artifact Registry

# Set variables
PROJECT_ID=gcp-apigee-playground-f2j3lk4j
REGION=asia-southeast1
REPO=apigee-demo-ar
IMAGE=apigee-playground-backend

# Authenticate with Google Cloud
gcloud auth login
gcloud config set project $PROJECT_ID

# Enable required services (if not already enabled)
gcloud services enable artifactregistry.googleapis.com run.googleapis.com

# Create Artifact Registry repo (if not already created)
gcloud artifacts repositories create $REPO \
  --repository-format=docker \
  --location=$REGION

# Build the Docker image
cd "01-Demo-Services/apigee-playground-backend"
docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE:latest .

# Push the image to Artifact Registry
docker push $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE:latest



3. Deploy to Cloud Run

```bash
gcloud run deploy $IMAGE \
  --image $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE:latest \
  --platform managed \
  --set-env-vars DUMMY_TOKEN=my-secret-token \
  --region $REGION \
  --allow-unauthenticated \
  --port 8080 \
  --memory 1Gi \
  --timeout 300
```


