// main.tf for 00-bootstrap
// This file calls all modules for foundational GCP resources

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

// ----------------------
// Enable Required APIs
// ----------------------
module "required_apis" {
  source      = "../modules/apis"
  project_id  = var.project_id
  api_services = [
    "apigee.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "cloudkms.googleapis.com",
    "run.googleapis.com",             
    "artifactregistry.googleapis.com" 
  ]
}

// ----------------------
// KMS Key Ring and Crypto Key
// ----------------------
module "apigee_kms" {
  source       = "../modules/kms"
  project_id   = var.project_id
  region       = var.region
  keyring_name = "apigee-eval-keyring"
  key_name     = "apigee-eval-disk-key"
}

// ----------------------
// Apigee Service Account and KMS Binding
// ----------------------
module "apigee_service_account" {
  source        = "../modules/service_account"
  project_id    = var.project_id
  service       = "apigee.googleapis.com"
  crypto_key_id = module.apigee_kms.crypto_key_id
}

// ----------------------
// VPC Networks
// ----------------------
module "vpcs" {
  source = "../modules/networking/vpc"
  vpcs   = var.vpcs
}

// ----------------------
// Subnets
// ----------------------

module "subnets" {
  source  = "../modules/networking/subnet"
  subnets = var.subnets
}

// ----------------------
// GCS Buckets
// ----------------------

module "gcs_buckets" {
  source  = "../modules/gcs"
  buckets = var.buckets
}

# // ----------------------
# // GKE Clusters
# // ----------------------

module "gke_clusters" {
  source   = "../modules/gke"
  clusters = var.clusters
}

// ----------------------
// Cloud Run Services
// ----------------------

module "cloud_run_services" {
  source   = "../modules/cr"
  services = var.services
}
