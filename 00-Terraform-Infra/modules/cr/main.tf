// In 00-Terraform-Infra/modules/cr/main.tf

variable "services" {
  description = "Map of Cloud Run service objects."
  type = map(object({
    name                  = string
    image                 = string
    location              = string
    allow_unauthenticated = optional(bool, false) # <-- ADD THIS LINE
    env                   = map(string)
  }))
}

resource "google_cloud_run_service" "services" {
  for_each = var.services
  name     = each.value.name
  location = each.value.location
  template {
    spec {
      containers {
        image = each.value.image
        dynamic "env" {
          for_each = each.value.env
          content {
            name  = env.key
            value = env.value
          }
        }
      }
    }
  }
}

# --- Cloud Run Service IAM Policy ---
resource "google_cloud_run_service_iam_member" "allow_public" {
    for_each = {
        for key, service in var.services: key => service
        if service.allow_unauthenticated == true
    }
    location = google_cloud_run_service.services[each.key].location
    project  = google_cloud_run_service.services[each.key].project
    service  = google_cloud_run_service.services[each.key].name
    role     = "roles/run.invoker"
    member   = "allUsers"
}

# ------------------------------------
# Outputs for Cloud Run Services
# ------------------------------------

output "service_names" {
  value = { for k, s in google_cloud_run_service.services : k => s.name }
}

output "service_urls" {
  value = { for k, s in google_cloud_run_service.services : k => s.status[0].url }
}