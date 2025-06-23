# Example tfvars for 00-bootstrap
project_id = "gcp-apigee-playground-f2j3lk4j"
region    = "asia-south1"

# GCS Buckets
buckets = {
  apigee_infra_gcs_bkt = {
    name          = "apgiee-infra-gcs-bkt"
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

# Cloud Run Services (example, can be empty if not needed)
services = {}
