provider "google" {
  project = var.project
  region  = var.region
}

# Create the network
resource "google_compute_network" "vpc" {
  name                            = var.network_name
  auto_create_subnetworks         = var.auto_create_subnet
  routing_mode                    = var.routing_mode
  project                         = var.project
  delete_default_routes_on_create = var.delete_default_routes
}

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
  provider         = google
  name             = var.webapp_route_name
  dest_range       = var.destination_range
  network          = google_compute_network.vpc.self_link
  next_hop_gateway = var.internet_gateway
  tags             = var.tags
  depends_on       = [google_compute_subnetwork.webapp_subnet]
}

resource "google_compute_firewall" "webapp_firewall" {
  name    = var.firewall_name
  network = google_compute_network.vpc.name
  allow {
    protocol = var.http_protocol
    ports    = var.firewall_tcp_allow_ports
  }
  source_tags   = var.tags
  source_ranges = var.firewall_source_ranges
  priority = var.firewall_allow_priority
}

resource "google_compute_firewall" "webapp_firewall_deny" {
  name    = var.firewall_deny_name
  network = google_compute_network.vpc.name
  deny {
    protocol = var.http_protocol
  }
  source_tags   = var.tags
  source_ranges = var.firewall_source_ranges
}

resource "google_compute_address" "webapp_address" {
  name = var.compute_address_name
}

resource "google_compute_instance" "webapp_instance" {
  name         = var.compute_instance_name
  machine_type = var.instance_machine_type
  zone         = var.instance_zone
  tags         = var.tags

  boot_disk {
    initialize_params {
      image = var.instance_app_image_family
      size  = var.instance_disk_size
      type  = var.instance_disk_type
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.webapp_subnet.self_link
    access_config {
      nat_ip = google_compute_address.webapp_address.address
    }
  }
}