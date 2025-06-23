// Module: apis
// Enables a set of Google Cloud APIs

variable "project_id" { type = string }
variable "api_services" { type = list(string) }

resource "google_project_service" "required_apis" {
  for_each = toset(var.api_services)
  project  = var.project_id
  service  = each.key
  disable_on_destroy = false
  disable_dependent_services = true
}

output "enabled_apis" {
  value = [for s in google_project_service.required_apis : s.service]
}
