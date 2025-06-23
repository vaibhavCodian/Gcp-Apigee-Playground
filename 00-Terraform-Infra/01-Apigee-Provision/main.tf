data "terraform_remote_state" "bootstrap" {
  backend = "gcs"
  config = {
    bucket = "apgiee-infra-gcs-bkt" # <-- Update to match the actual provisioned bucket name (all lowercase, no typos)
    prefix = "terraform/state/bootstrap"
  }
}

# -------------------------------------------------------------------------------------
# 1. ENABLE REQUIRED GOOGLE CLOUD APIS
# -------------------------------------------------------------------------------------

resource "google_project_service" "required_apis" {
  for_each = toset([
    "apigee.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "cloudkms.googleapis.com"
  ])

  project                    = var.project_id
  service                    = each.key
  disable_on_destroy         = false
  disable_dependent_services = true
}

# -------------------------------------------------------------------------------------
# 2. USE BOOTSTRAP-PROVISIONED VPC, SUBNET, KMS, SERVICE ACCOUNT
# -------------------------------------------------------------------------------------

# Example usage:
# data.terraform_remote_state.bootstrap.outputs.apigee_vpc_id
# data.terraform_remote_state.bootstrap.outputs.apigee_kms_key_id
# data.terraform_remote_state.bootstrap.outputs.apigee_service_account_email
# data.terraform_remote_state.bootstrap.outputs.subnet_self_links


# -------------------------------------------------------------------------------------
# 3. CLOUD KMS KEY FOR ENCRYPTION (from bootstrap)
# -------------------------------------------------------------------------------------
# Use data.terraform_remote_state.bootstrap.outputs.apigee_kms_key_id

# -------------------------------------------------------------------------------------
# 4. PROVISION APIGEE EVALUATION ORGANIZATION AND RUNTIME
# -------------------------------------------------------------------------------------

resource "google_apigee_organization" "eval_org" {
  project_id       = var.project_id
  analytics_region = var.region
  runtime_type     = "CLOUD"
  billing_type     = "EVALUATION"
  authorized_network = data.terraform_remote_state.bootstrap.outputs.apigee_vpc_id
  depends_on = [google_project_service.required_apis]
}

resource "google_apigee_instance" "eval_instance" {
  name                     = "eval-instance-${var.region}"
  org_id                   = google_apigee_organization.eval_org.id
  location                 = var.region
  disk_encryption_key_name = data.terraform_remote_state.bootstrap.outputs.apigee_kms_key_id
  depends_on = [google_apigee_organization.eval_org]
}

resource "google_apigee_environment" "eval_env" {
  org_id      = google_apigee_organization.eval_org.id
  name        = "eval-1"
  description = "Evaluation Environment"
  depends_on = [google_apigee_instance.eval_instance]
}

resource "google_apigee_envgroup" "eval_group" {
  org_id     = google_apigee_organization.eval_org.id
  name       = "eval-group"
  hostnames = ["${google_apigee_instance.eval_instance.host}.nip.io"]
  depends_on = [google_apigee_instance.eval_instance]
}

resource "google_apigee_envgroup_attachment" "eval_attachment" {
  envgroup_id  = google_apigee_envgroup.eval_group.id
  environment  = google_apigee_environment.eval_env.name
}