terraform {
  backend "gcs" {
    bucket = "apgiee-infra-gcs-bkt-17523"
    prefix = "terraform/state/bootstrap"
  }
}
