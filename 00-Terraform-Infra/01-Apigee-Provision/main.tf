/**
 * Simple Apigee Environment Terraform Configuration
 * Provisions a basic Apigee environment with external accessibility
 */
terraform {
  required_version = ">=1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.6.4"
    }
  }
}

# Variables
variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "peaceful-tide-466409-q7"
}

variable "runtime_location" {
  description = "Runtime Loacation of Apigee Instance"
  type        = string
  default     = "asia-southeast1"
}

variable "analytics_region" {
  description = "Analytics region for Apigee"
  type        = string
  default     = "asia-southeast1"
}

# Provider configuration
provider "google" {
  project = var.project_id
  region  = var.runtime_location
}

# External IP Address First (Needed for nip.io domain)

resource "google_compute_global_address" "apigee_external_ip" {
  name    = "apigee-external-ip"
  project = var.project_id
}

# Create nip.io domain from the External IP Address
locals {
  nip_io_domain = "${google_compute_global_address.apigee_external_ip.address}.nip.io"
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "apigee.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com"
  ])

  project = var.project_id
  service = each.value

  disable_dependent_services = true
  disable_on_destroy         = false
}


# Create Apigee Organization (Eval) - No VPC Peering
resource "google_apigee_organization" "apigee_org" {
  analytics_region    = var.analytics_region
  project_id          = var.project_id
  runtime_type        = "CLOUD"
  billing_type        = "EVALUATION"
  disable_vpc_peering = true

  depends_on = [google_project_service.required_apis]
}

# Create Environment Group
resource "google_apigee_envgroup" "eval_envgroup" {
  name      = "eval-envgroup"
  hostnames = [local.nip_io_domain]
  org_id    = google_apigee_organization.apigee_org.id

  depends_on = [google_apigee_organization.apigee_org]
}

# Create Environment
resource "google_apigee_environment" "eval_env" {
  name         = "eval-env"
  description  = "Eval Environment"
  display_name = "Eval Environment"
  org_id       = google_apigee_organization.apigee_org.id
}


# Attach Environment to Environment Group
resource "google_apigee_envgroup_attachment" "eval_attachment" {
  envgroup_id = google_apigee_envgroup.eval_envgroup.id
  environment = google_apigee_environment.eval_env.name
}

# Create Apigee Instance
resource "google_apigee_instance" "eval_apigee_instance" {
  name     = "eval-apigee-instance"
  location = var.runtime_location
  org_id   = google_apigee_organization.apigee_org.id

  depends_on = [google_apigee_organization.apigee_org]
}

# Attach Instance to Environment
resource "google_apigee_instance_attachment" "eval_instance_attachment" {
  instance_id = google_apigee_instance.eval_apigee_instance.id
  environment = google_apigee_environment.eval_env.name
  depends_on = [
    google_apigee_environment.eval_env,
    google_apigee_instance.eval_apigee_instance
  ]
}

# Wait For Apigee Instance to be Ready / Fully Deployed
resource "time_sleep" "wait_for_apigee_instance" {
  depends_on      = [google_apigee_instance_attachment.eval_instance_attachment]
  create_duration = "2m"
}

###############################################
# PSC and NEG Setup For External Access
###############################################


# Create PSC Network Endpoint Group (Regional)
resource "google_compute_region_network_endpoint_group" "apigee_psc_neg" {
  name = "apigee-psc-neg"
  network = "projects/${var.project_id}/global/networks/default"
  subnetwork = "projects/${var.project_id}/regions/${var.runtime_location}/subnetworks/default"
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  project               = var.project_id
  region                = var.runtime_location
  psc_target_service    = google_apigee_instance.eval_apigee_instance.service_attachment

  depends_on = [time_sleep.wait_for_apigee_instance]
}

# Create Backend Service For Apigee 
resource "google_compute_backend_service" "apigee_backend_service" {
  name                            = "apigee-backend-service"
  project                         = var.project_id
  protocol                        = "HTTP"
  port_name                       = "http"
  timeout_sec                     = 30
  connection_draining_timeout_sec = 60
  load_balancing_scheme           = "EXTERNAL_MANAGED"

  backend {
    group           = google_compute_region_network_endpoint_group.apigee_psc_neg.id
  }

  # PSC NEGs don't Suport Health Checks
  depends_on = [google_compute_region_network_endpoint_group.apigee_psc_neg]
}

# Create Managed SSL Certificate For nip.io Domain
resource "google_compute_managed_ssl_certificate" "apigee_ssl_cert" {
  name    = "apigee-ssl-cert"
  project = var.project_id

  managed {
    domains = [local.nip_io_domain]
  }

  lifecycle {
    create_before_destroy = false
  }
}
# Create URL Map
resource "google_compute_url_map" "apigee_url_map" {
  name            = "apigee-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.apigee_backend_service.self_link
}

# Create HTTPs Target Proxy.
resource "google_compute_target_https_proxy" "apigee_https_proxy" {
  name             = "apigee-https-proxy"
  project          = var.project_id
  url_map          = google_compute_url_map.apigee_url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.apigee_ssl_cert.self_link]
}

# Create HTTP Target Proxy.
resource "google_compute_target_http_proxy" "apigee_http_proxy" {
  name    = "apigee-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.apigee_url_map.self_link
}

# Create Global Forwarding Rule for HTTPS
resource "google_compute_global_forwarding_rule" "apigee_https_forwarding_rule" {
  name                  = "apigee-https-forwarding-rule"
  project               = var.project_id
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.apigee_https_proxy.self_link
  ip_address            = google_compute_global_address.apigee_external_ip.id

  depends_on = [google_compute_global_address.apigee_external_ip]
}

# Create Global Forwarding Rule for HTTP
resource "google_compute_global_forwarding_rule" "apigee_http_forwarding_rule" {
  name                  = "apigee-http-forwarding-rule"
  project               = var.project_id
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.apigee_http_proxy.self_link
  ip_address            = google_compute_global_address.apigee_external_ip.id

  depends_on = [google_compute_global_address.apigee_external_ip, google_compute_target_http_proxy.apigee_http_proxy]
}

# Create Firewall Rule to Allow HTTP/HTTPS Traffic
resource "google_compute_firewall" "apigee_http_https_firewall" {
  name          = "apigee-http-https-firewall"
  project       = var.project_id
  network       = "default"
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

# OUTPUTS 
output "apigee_external_ip" {
  value       = google_compute_global_address.apigee_external_ip.address
  description = "External IP address for Apigee instance"
}
output "apigee_nip_io_domain" {
  value       = local.nip_io_domain
  description = "Nip.io domain for Apigee instance"
}


output "apigee_config" {
  value = {
    external_ip        = google_compute_global_address.apigee_external_ip.address
    nip_io_domain      = local.nip_io_domain
    org_id             = google_apigee_organization.apigee_org.id
    billing_type       = google_apigee_organization.apigee_org.billing_type
    runtime_type       = google_apigee_organization.apigee_org.runtime_type
    instance_name      = google_apigee_instance.eval_apigee_instance.name
    environment_name   = google_apigee_environment.eval_env.name
    envgroup_name      = google_apigee_envgroup.eval_envgroup.name
    apigee_console_proxies_url = "https://console.cloud.google.com/apigee/proxies?project=${var.project_id}&organization=${google_apigee_organization.apigee_org.id}&environment=${google_apigee_environment.eval_env.name}"

  }
  description = "Configuration details for the Apigee deployment"
}
