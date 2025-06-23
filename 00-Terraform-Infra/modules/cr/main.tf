// Cloud Run module
// Expects a map of objects for multiple service creation

variable "services" {
  description = "Map of Cloud Run service objects."
  type        = map(object({
    name     = string
    image    = string
    location = string
    env      = map(string)
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

output "service_names" {
  value = [for s in google_cloud_run_service.services : s.name]
}
