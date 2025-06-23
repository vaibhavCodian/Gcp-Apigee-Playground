// Module: service_account
// Provisions a service identity and binds it to a KMS key

variable "project_id" { type = string }
variable "service" { type = string }
variable "crypto_key_id" { type = string }

resource "google_project_service_identity" "sa" {
  provider = google-beta
  project  = var.project_id
  service  = var.service
}

resource "google_kms_crypto_key_iam_member" "kms_binding" {
  crypto_key_id = var.crypto_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.sa.email}"
}

output "service_account_email" {
  value = google_project_service_identity.sa.email
}
