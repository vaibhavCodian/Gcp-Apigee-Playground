// variables.tf for 00-bootstrap

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "vpcs" {
  description = "Map of VPC objects for VPC module"
  type = map(object({
    name = string
    auto_create_subnetworks = bool
  }))
  default = {}
}

variable "subnets" {
  description = "Map of subnet objects for Subnet module"
  type = map(object({
    name          = string
    ip_cidr_range = string
    region        = string
    network       = string
  }))
  default = {}
}

variable "buckets" {
  description = "Map of GCS bucket objects for GCS module"
  type = map(object({
    name          = string
    location      = string
    storage_class = string
    force_destroy = bool
  }))
  default = {}
}

variable "clusters" {
  description = "Map of GKE cluster objects for GKE module"
  type = map(object({
    name     = string
    location = string
    initial_node_count = number
    node_config = object({
      machine_type = string
    })
  }))
  default = {}
}

variable "services" {
  description = "Map of Cloud Run service objects for Cloud Run module"
  type = map(object({
    name     = string
    image    = string
    location = string
    env      = map(string)
  }))
  default = {}
}
