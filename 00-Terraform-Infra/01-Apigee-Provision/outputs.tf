# -------------------------------------------------------------------------------------
# OUTPUTS
# -------------------------------------------------------------------------------------

output "apigee_organization_id" {
  description = "The ID of the provisioned Apigee organization."
  value       = google_apigee_organization.eval_org.id
}

# output "apigee_environment_group_hostname" {
#   description = "The public hostname for the evaluation environment group. Use this to call your deployed API proxies."
#   value       = google_apigee_envgroup.eval_group.hostnames[0]
#   sensitive   = false
# }

output "apigee_environment_name" {
  description = "The name of the provisioned evaluation environment."
  value       = google_apigee_environment.eval_env.name
}

output "apigee_instance_name" {
    description = "The name of the Apigee instance."
    value = google_apigee_instance.eval_instance.name
}