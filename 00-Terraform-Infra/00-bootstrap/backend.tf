# backend.tf for 00-bootstrap
#
# Uncomment and update the bucket name after the first apply to use remote state.
#
terraform {
  backend "gcs" {
    bucket  = "apgiee-infra-gcs-bkt" # <-- Update to match the provisioned bucket name
    prefix  = "terraform/state/bootstrap"
  }
}
