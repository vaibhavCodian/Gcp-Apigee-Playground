// VPC module
// Expects a map of objects for multiple VPC creation

variable "vpcs" {
  description = "Map of VPC objects."
  type        = map(object({
    name = string
    auto_create_subnetworks = bool
  }))
}

resource "google_compute_network" "vpcs" {
  for_each                = var.vpcs
  name                    = each.value.name
  auto_create_subnetworks = each.value.auto_create_subnetworks
}

output "vpc_names" {
  value = [for v in google_compute_network.vpcs : v.name]
}

output "vpc_ids" {
  value = { for k, v in google_compute_network.vpcs : v.name => v.id }
}
