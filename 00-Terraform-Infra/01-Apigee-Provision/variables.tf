# -------------------------------------------------------------------------------------
# INPUT VARIABLES
# -------------------------------------------------------------------------------------

variable "project_id" {
  description = "The GCP project ID to deploy Apigee into."
  type        = string
  default     = "gcp-apigee-playground-f2j3lk4j"
}

variable "region" {
  description = "The GCP region for Apigee resources (analytics and runtime)."
  type        = string
  default     = "asia-south1" # Mumbai
}

variable "apigee_network_name" {
  description = "Name of the Apigee VPC network provisioned in bootstrap."
  type        = string
}