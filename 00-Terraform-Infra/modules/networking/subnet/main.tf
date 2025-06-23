// Subnet module
// Expects a map of objects for multiple subnet creation

variable "subnets" {
  description = "Map of subnet objects."
  type        = map(object({
    name          = string
    ip_cidr_range = string
    region        = string
    network       = string
  }))
}

resource "google_compute_subnetwork" "subnets" {
  for_each      = var.subnets
  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  network       = each.value.network
}

output "subnet_names" {
  value = [for s in google_compute_subnetwork.subnets : s.name]
}

output "subnet_self_links" {
  value       = [for s in google_compute_subnetwork.subnets : s.self_link]
  description = "Self-links of all provisioned subnets."
}
