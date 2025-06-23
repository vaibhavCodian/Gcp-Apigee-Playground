# -------------------------------------------------------------------------------------
# CONFIGURE TERRAFORM & GOOGLE CLOUD PROVIDER
# -------------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.70.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}