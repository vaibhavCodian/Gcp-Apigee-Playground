# backend.tf for 01-Apigee-Provision

terraform {
  backend "gcs" {
    bucket = "peaceful-tide-tf-state-bkt-5234" 
    prefix = "terraform/state/apigee-provision-2"
  }
}

