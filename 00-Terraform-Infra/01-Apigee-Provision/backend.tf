# backend.tf for 01-Apigee-Provision

terraform {
  backend "gcs" {
    bucket  = "apgiee-infra-gcs-bkt" 
    prefix  = "terraform/state/apigee-provision"
  }
}
