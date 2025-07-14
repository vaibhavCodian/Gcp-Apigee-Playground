/**
 * Simple Apigee Environment Terraform Configuration
 * Provisions a basic Apigee environment with external accessibility
 */

# Variables
variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "gcp-apigee-playground-vs-17523"
}

variable "apigee_network_name" {
  description = "Name for the Apigee VPC network"
  type        = string
  default     = "apigee-vpc"
}

variable "instance_region" {
  description = "Region for Apigee instance"
  type        = string
  default     = "us-central1"
}

variable "analytics_region" {
  description = "Analytics region for Apigee"
  type        = string
  default     = "us-central1"
}

# Provider configuration
provider "google" {
  project = var.project_id
  region  = var.instance_region
}

# Local values
locals {
  hostname    = "${google_compute_global_address.apigee_external_ip.address}.nip.io"
  environment = "dev"
  envgroup    = "apis"
  
  environments = {
    (local.environment) = {
      envgroups = [local.envgroup]
    }
  }
  
  instances = {
    (var.instance_region) = {
      environments = keys(local.environments)
    }
  }
}

# Enable required APIs
resource "google_project_service" "apigee_services" {
  for_each = toset([
    "apigee.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com"
  ])
  
  project = var.project_id
  service = each.value
  
  disable_dependent_services = true
}

# Create VPC Network
resource "google_compute_network" "apigee_network" {
  name                    = var.apigee_network_name
  auto_create_subnetworks = false
  project                 = var.project_id
  
  depends_on = [google_project_service.apigee_services]
}

# Create subnet for Apigee
resource "google_compute_subnetwork" "apigee_subnet" {
  name          = "apigee-subnet-${var.instance_region}"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.instance_region
  network       = google_compute_network.apigee_network.id
  project       = var.project_id
  
  private_ip_google_access = true
}

# Create PSC subnet for Apigee
resource "google_compute_subnetwork" "apigee_psc_subnet" {
  name          = "apigee-psc-subnet-${var.instance_region}"
  ip_cidr_range = "10.1.0.0/24"
  region        = var.instance_region
  network       = google_compute_network.apigee_network.id
  project       = var.project_id
  purpose       = "PRIVATE_SERVICE_CONNECT"
}

# Create proxy-only subnet for load balancer
resource "google_compute_subnetwork" "proxy_only_subnet" {
  name          = "proxy-only-subnet-${var.instance_region}"
  ip_cidr_range = "10.2.0.0/24"
  region        = var.instance_region
  network       = google_compute_network.apigee_network.id
  project       = var.project_id
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

# Reserve IP range for service networking
resource "google_compute_global_address" "service_range" {
  name          = "apigee-service-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.apigee_network.id
  project       = var.project_id
}

# Create service networking connection
resource "google_service_networking_connection" "apigee_service_networking" {
  network                 = google_compute_network.apigee_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.service_range.name]
  
  depends_on = [
    google_project_service.apigee_services,
    google_compute_global_address.service_range
  ]
}

# Reserve external IP for load balancer
resource "google_compute_global_address" "apigee_external_ip" {
  name    = "apigee-external-ip"
  project = var.project_id
}

# Create Apigee Organization
resource "google_apigee_organization" "apigee_org" {
  analytics_region   = var.analytics_region
  project_id        = var.project_id
  authorized_network = google_compute_network.apigee_network.id
  runtime_type      = "CLOUD"
  billing_type      = "EVALUATION"
  retention         = "MINIMUM"
  disable_vpc_peering = false
  
  depends_on = [
    google_project_service.apigee_services,
    google_compute_network.apigee_network,
    google_service_networking_connection.apigee_service_networking
  ]
}

# Create Apigee Environment Group
resource "google_apigee_envgroup" "apigee_envgroup" {
  name         = local.envgroup
  hostnames    = [local.hostname]
  org_id       = google_apigee_organization.apigee_org.id
}

# Create Apigee Environment
resource "google_apigee_environment" "apigee_environment" {
  name         = local.environment
  description  = "Development environment"
  org_id       = google_apigee_organization.apigee_org.id
  display_name = "Development"
}

# Attach Environment to Environment Group
resource "google_apigee_envgroup_attachment" "apigee_envgroup_attachment" {
  envgroup_id = google_apigee_envgroup.apigee_envgroup.id
  environment = google_apigee_environment.apigee_environment.name
}

# Create Apigee Instance
resource "google_apigee_instance" "apigee_instance" {
  name               = "apigee-instance-${var.instance_region}"
  location           = var.instance_region
  org_id             = google_apigee_organization.apigee_org.id
  peering_cidr_range = "SLASH_22"
  
  depends_on = [
    google_apigee_organization.apigee_org,
    google_service_networking_connection.apigee_service_networking
  ]
}

# Attach Instance to Environment
resource "google_apigee_instance_attachment" "apigee_instance_attachment" {
  instance_id = google_apigee_instance.apigee_instance.id
  environment = google_apigee_environment.apigee_environment.name
}

# Create Network Endpoint Group for Apigee
resource "google_compute_region_network_endpoint_group" "apigee_neg" {
  name                  = "apigee-neg-${var.instance_region}"
  region                = var.instance_region
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = google_apigee_instance.apigee_instance.service_attachment
  network               = google_compute_network.apigee_network.id
  subnetwork            = google_compute_subnetwork.apigee_psc_subnet.id
  project               = var.project_id
  
  depends_on = [
    google_apigee_instance.apigee_instance,
    google_apigee_instance_attachment.apigee_instance_attachment
  ]
}

# Create Backend Service WITHOUT health checks (PSC NEGs don't support them)
resource "google_compute_backend_service" "apigee_backend" {
  name                            = "apigee-backend-service"
  project                         = var.project_id
  protocol                        = "HTTPS"
  port_name                       = "https"
  timeout_sec                     = 30
  connection_draining_timeout_sec = 60
  
  backend {
    group = google_compute_region_network_endpoint_group.apigee_neg.id
  }
  
  depends_on = [google_compute_region_network_endpoint_group.apigee_neg]
}

# Create URL Map
resource "google_compute_url_map" "apigee_url_map" {
  name            = "apigee-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.apigee_backend.id
}

# Create SSL Certificate
resource "google_compute_managed_ssl_certificate" "apigee_ssl_cert" {
  name    = "apigee-ssl-cert"
  project = var.project_id
  
  managed {
    domains = [local.hostname]
  }
}

# Create HTTPS Proxy
resource "google_compute_target_https_proxy" "apigee_https_proxy" {
  name             = "apigee-https-proxy"
  project          = var.project_id
  url_map          = google_compute_url_map.apigee_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.apigee_ssl_cert.id]
}

# Create Global Forwarding Rule for HTTPS
resource "google_compute_global_forwarding_rule" "apigee_forwarding_rule" {
  name                  = "apigee-forwarding-rule"
  project               = var.project_id
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443"
  target                = google_compute_target_https_proxy.apigee_https_proxy.id
  ip_address            = google_compute_global_address.apigee_external_ip.id
}

# Create HTTP Proxy for debugging/testing
resource "google_compute_target_http_proxy" "apigee_http_proxy" {
  name    = "apigee-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.apigee_url_map.id
}

# Create Global Forwarding Rule for HTTP
resource "google_compute_global_forwarding_rule" "apigee_forwarding_rule_http" {
  name                  = "apigee-forwarding-rule-http"
  project               = var.project_id
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.apigee_http_proxy.id
  ip_address            = google_compute_global_address.apigee_external_ip.id
}

# Create firewall rule to allow health checks
resource "google_compute_firewall" "allow_health_check" {
  name    = "apigee-allow-health-check"
  network = google_compute_network.apigee_network.name
  project = var.project_id
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  direction     = "INGRESS"
}

# Create firewall rule to allow proxy-only subnet
resource "google_compute_firewall" "allow_proxy_only_subnet" {
  name    = "apigee-allow-proxy-only-subnet"
  network = google_compute_network.apigee_network.name
  project = var.project_id
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  source_ranges = ["10.2.0.0/24"]
  direction     = "INGRESS"
}

# Create firewall rule to allow PSC subnet
resource "google_compute_firewall" "allow_psc_subnet" {
  name    = "apigee-allow-psc-subnet"
  network = google_compute_network.apigee_network.name
  project = var.project_id
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  source_ranges = ["10.1.0.0/24"]
  direction     = "INGRESS"
}

# Create NAT Gateway for outbound connectivity
resource "google_compute_router" "apigee_router" {
  name    = "apigee-router"
  region  = var.instance_region
  network = google_compute_network.apigee_network.id
  project = var.project_id
}

resource "google_compute_router_nat" "apigee_nat" {
  name                               = "apigee-nat"
  router                             = google_compute_router.apigee_router.name
  region                             = var.instance_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = var.project_id
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Outputs
output "apigee_organization_name" {
  description = "Name of the Apigee organization"
  value       = google_apigee_organization.apigee_org.id
}

output "apigee_environment_name" {
  description = "Name of the Apigee environment"
  value       = google_apigee_environment.apigee_environment.name
}

output "apigee_instance_name" {
  description = "Name of the Apigee instance"
  value       = google_apigee_instance.apigee_instance.name
}

output "external_ip_address" {
  description = "External IP address for Apigee"
  value       = google_compute_global_address.apigee_external_ip.address
}

output "apigee_hostname" {
  description = "Hostname for accessing Apigee"
  value       = local.hostname
}

output "apigee_console_url" {
  description = "URL to access Apigee console"
  value       = "https://console.cloud.google.com/apigee/environments?project=${var.project_id}"
}

output "debugging_commands" {
  description = "Commands to debug the setup"
  value = {
    check_ssl_cert = "gcloud compute ssl-certificates describe apigee-ssl-cert --global --project=${var.project_id}"
    check_backend  = "gcloud compute backend-services describe apigee-backend-service --global --project=${var.project_id}"
    check_neg      = "gcloud compute network-endpoint-groups describe apigee-neg-${var.instance_region} --region=${var.instance_region} --project=${var.project_id}"
    check_instance = "gcloud apigee instances describe apigee-instance-${var.instance_region} --organization=${var.project_id} --format='value(state)'"
  }
}