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
  name                     = var.db_subnet_name
  network                  = google_compute_network.vpc.name
  ip_cidr_range            = var.ip_cidr_range_db
  region                   = var.region
  project                  = var.project
  private_ip_google_access = true
}

resource "google_compute_global_address" "default" {
  project       = var.project
  name          = "global-psconnect-ip"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.default.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "my_instance" {
  name                = "mysql-instance-${random_id.db_name_suffix.hex}"
  database_version    = "MYSQL_8_0"
  region              = var.region
  deletion_protection = false
  depends_on          = [google_service_networking_connection.default]
  settings {
    tier = "db-f1-micro"

    availability_type = "REGIONAL"
    disk_type         = "pd-ssd"
    disk_size         = "100"
    disk_autoresize   = false

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.vpc.id
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      binary_log_enabled = true
      enabled            = true
    }
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "google_sql_user" "users" {
  name     = "webapp"
  instance = google_sql_database_instance.my_instance.name
  password = random_password.password.result
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
  priority      = var.firewall_allow_priority
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
  metadata = {
    startup-script = <<-EOF
#!/bin/bash

if [ ! -f "/opt/db.properties" ] 
then
sudo touch /opt/db.properties

sudo echo "spring.datasource.url=jdbc:mysql://${google_sql_database_instance.my_instance.first_ip_address}:3306/${google_sql_database_instance.my_instance.name}?createDatabaseIfNotExist=true" >> /opt/db.properties
sudo echo "spring.datasource.username=${google_sql_user.users.name}" >> /opt/db.properties
sudo echo "spring.datasource.password=${google_sql_user.users.password}" >> /opt/db.properties
sudo echo "spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver" >> /opt/db.properties
sudo echo "spring.jpa.hibernate.ddl-auto=update" >> /opt/db.properties
sudo echo "spring.jpa.show-sql=true" >> /opt/db.properties
sudo echo "spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect" >> /opt/db.properties

sudo chown -R csye6225:csye6225 /opt/db.properties
else
sudo echo "db.properties already exists" >> /var/log/csye6225/app.log
fi
EOF
  }
}