// outputs.tf for 00-bootstrap

output "vpc_names" {
  value = module.vpcs.vpc_names
}

output "subnet_names" {
  value = module.subnets.subnet_names
}

output "bucket_names" {
  value = module.gcs_buckets.bucket_names
}

output "cluster_names" {
  value = module.gke_clusters.cluster_names
}

output "service_names" {
  value = module.cloud_run_services.service_names
}

output "apigee_vpc_id" {
  value       = module.vpcs.vpc_ids["apigee-vpc"] # Replace with your actual VPC name if different
  description = "ID of the Apigee VPC network."
}

output "apigee_kms_key_id" {
  value       = module.apigee_kms.crypto_key_id
  description = "ID of the Apigee KMS crypto key."
}

output "apigee_kms_keyring_id" {
  value       = module.apigee_kms.keyring_id
  description = "ID of the Apigee KMS key ring."
}

output "apigee_service_account_email" {
  value       = module.apigee_service_account.service_account_email
  description = "Email of the Apigee service account."
}

output "subnet_self_links" {
  value       = module.subnets.subnet_self_links
  description = "Self-links of all provisioned subnets."
}
