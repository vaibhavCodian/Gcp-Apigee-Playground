// Module: kms
// Provisions a KMS key ring and crypto key

variable "project_id" { type = string }
variable "region" { type = string }
variable "keyring_name" { type = string }
variable "key_name" { type = string }

resource "google_kms_key_ring" "keyring" {
  project  = var.project_id
  name     = var.keyring_name
  location = var.region
}

resource "google_kms_crypto_key" "key" {
  name     = var.key_name
  key_ring = google_kms_key_ring.keyring.id
  purpose  = "ENCRYPT_DECRYPT"
}

output "keyring_id" {
  value = google_kms_key_ring.keyring.id
}

output "crypto_key_id" {
  value = google_kms_crypto_key.key.id
}
