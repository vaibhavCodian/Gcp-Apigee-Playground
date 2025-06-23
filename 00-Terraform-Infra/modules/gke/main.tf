// GKE Cluster module
// Expects a map of objects for multiple cluster creation

variable "clusters" {
  description = "Map of GKE cluster objects."
  type        = map(object({
    name     = string
    location = string
    initial_node_count = number
    node_config = object({
      machine_type = string
    })
  }))
}

resource "google_container_cluster" "clusters" {
  for_each           = var.clusters
  name               = each.value.name
  location           = each.value.location
  initial_node_count = each.value.initial_node_count
  node_config {
    machine_type = each.value.node_config.machine_type
  }
}

output "cluster_names" {
  value = [for c in google_container_cluster.clusters : c.name]
}
