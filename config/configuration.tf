provider "google" {
  project = var.project
  region = var.region
}

# Create the network
resource "google_compute_network" "vpc" {
  name = var.network_name
  auto_create_subnetworks = false
  routing_mode = "REGIONAL"
  project = var.project
  delete_default_routes_on_create = true
}

# Create webapp subnet
resource "google_compute_subnetwork" "webapp_subnet" {
  name          = var.webapp_subnet_name
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.ip_cidr_range_webapp
  region        = var.region
  project = var.project
}

# Create db subnet
resource "google_compute_subnetwork" "db_subnet" {
  name          = var.db_subnet_name
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.ip_cidr_range_db
  region        = var.region
  project = var.project
}

resource "google_compute_health_check" "health_check" {
  provider           = google-beta
  name               = var.health_check_name
  project = var.project
  check_interval_sec = 1
  timeout_sec        = 1

  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_region_backend_service" "backend" {
  provider      = google-beta
  name          = var.backend_name
  project = var.project
  region        = var.region
  health_checks = [google_compute_health_check.health_check.id]
}

# Adding a forwarding rule for the webapp route
resource "google_compute_forwarding_rule" "vpc_forwarding_rule" {
  provider = google
  name     = var.forwarding_rule_name
  region   = var.region

  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  network               = google_compute_network.vpc.name
  subnetwork            = google_compute_subnetwork.webapp_subnet.name
  backend_service       = google_compute_region_backend_service.backend.id 
}

# Create a route for webapp subnet
resource "google_compute_route" "webapp_route" {
  provider     = google
  name         = var.webapp_route_name
  dest_range   = "0.0.0.0/0"
  network      = google_compute_network.vpc.name
  next_hop_ilb = google_compute_forwarding_rule.vpc_forwarding_rule.ip_address
}