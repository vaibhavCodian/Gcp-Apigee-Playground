# Example tfvars for 00-bootstrap
project_id = "gcp-apigee-playground-vs-17523"
region    = "asia-south1"

# GCS Buckets
buckets = {
  apigee_infra_gcs_bkt = {
    name          = "apgiee-infra-gcs-bkt-17523"
    location      = "asia-south1"
    storage_class = "STANDARD"
    force_destroy = true
  }
}

# VPCs
vpcs = {
  apigee_vpc = {
    name                    = "apigee-vpc"
    auto_create_subnetworks = false
  }
}

# Subnets
subnets = {
  apigee_subnet = {
    name          = "apigee-subnet"
    ip_cidr_range = "10.10.0.0/24"
    region        = "asia-south1"
    network       = "apigee-vpc"
  }
}

# GKE Clusters (example, can be empty if not needed)
clusters = {}

services = {

  # Example Cloud Run service for demonstration purposes
  # This service is a simple "Hello World" application.
  
  hello-cr = {
    name     = "hello-cloud-run-svc"
    // This public image is for demonstration.
    // In a real pipeline, you would build and push your own image.
    image    = "gcr.io/cloudrun/hello" 
    location = "asia-south1"
    // 'allow_unauthenticated' is set to true for direct access initially,
    // but Apigee will add the security layer.
    allow_unauthenticated = true 
    env = {}
  }
}
