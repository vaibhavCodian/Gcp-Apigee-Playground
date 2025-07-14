# backend.tf for 01-Apigee-Provision

terraform {
  backend "gcs" {
    bucket = "apgiee-infra-gcs-bkt-17523" 
    prefix = "terraform/state/apigee-provision"
  }
}

