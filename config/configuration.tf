provider "google" {
  project = var.project
  region  = var.region
}

# Create the network
resource "google_compute_network" "vpc" {
  name                              = var.network_name
  auto_create_subnetworks           = var.auto_create_subnet
  routing_mode                      = var.routing_mode
  project                           = var.project
  delete_default_routes_on_create   = var.delete_default_routes

# Create webapp subnet
resource "google_compute_subnetwork" "webapp_subnet" {
  name          = var.webapp_subnet_name
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.ip_cidr_range_webapp
  region        = var.region
  project       = var.project
}

# Create db subnet
resource "google_compute_subnetwork" "db_subnet" {
  name          = var.db_subnet_name
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.ip_cidr_range_db
  region        = var.region
  project       = var.project
}

# Create a route for webapp subnet
resource "google_compute_route" "webapp_route" {
  provider     = google
  name         = var.webapp_route_name
  dest_range   = var.destination_range
  network      = google_compute_network.vpc.self_link
  next_hop_gateway = var.internet_gateway
}
