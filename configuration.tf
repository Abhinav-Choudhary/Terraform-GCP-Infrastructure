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
  private_ip_google_access = var.private_ip_google_access
}

# Create the compute global address
resource "google_compute_global_address" "webapp_global_address" {
  project       = var.project
  name          = var.global_address_name
  address_type  = var.global_address_type
  purpose       = var.global_address_purpose
  prefix_length = var.global_address_prefix_length
  network       = google_compute_network.vpc.id
}

# Add service networking connection
resource "google_service_networking_connection" "webapp_service_networking_connection" {
  network                 = google_compute_network.vpc.id
  service                 = var.service_networking_connection_service
  reserved_peering_ranges = [google_compute_global_address.webapp_global_address.name]
}

# Generate random id for CloudSQL instance name
resource "random_id" "db_instance_name_suffix" {
  byte_length = var.db_instance_name_suffix_length
}

# Setup CloudSQL database
resource "google_sql_database_instance" "database_instance" {
  name                = "${var.sql_database_instance_name}-${random_id.db_instance_name_suffix.hex}"
  database_version    = var.sql_database_instance_version
  region              = var.region
  deletion_protection = var.sql_database_instance_deletion_protection
  depends_on          = [google_service_networking_connection.webapp_service_networking_connection]
  settings {
    tier = var.sql_database_instance_tier

    availability_type = var.sql_database_instance_availability_type
    disk_type         = var.sql_database_instance_disk_type
    disk_size         = var.sql_database_instance_disk_size
    disk_autoresize   = var.sql_database_instance_disk_autoresize

    ip_configuration {
      ipv4_enabled                                  = var.sql_database_instance_ipv4_enabled
      private_network                               = google_compute_network.vpc.id
      enable_private_path_for_google_cloud_services = var.sql_database_instance_enable_private_path
    }

    backup_configuration {
      binary_log_enabled = var.sql_database_instance_binary_logs
      enabled            = var.sql_database_instance_backup_enabled
    }
  }
}

# Create a database using database instance
resource "google_sql_database" "database" {
  name     = var.sql_database_name
  instance = google_sql_database_instance.database_instance.name
}

# Generate random password for CloudSQL users
resource "random_password" "password" {
  length           = var.password_length
  special          = var.password_special
  override_special = var.password_override_special
}

# Create CloudSQL user
resource "google_sql_user" "users" {
  name     = var.sql_user_name
  instance = google_sql_database_instance.database_instance.name
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

# Add firewall rule to deny every port in tcp
resource "google_compute_firewall" "webapp_firewall_deny" {
  name    = var.firewall_deny_name
  network = google_compute_network.vpc.name
  deny {
    protocol = var.http_protocol
  }
  source_tags   = var.tags
  source_ranges = var.firewall_source_ranges
}

# External address for webapp subnet
resource "google_compute_address" "webapp_address" {
  name = var.compute_address_name
}

# Create service account
resource "google_service_account" "logging_service_account" {
  account_id   = var.logging_account_id
  display_name = var.logging_display_name
}

# Add logging admin role to service account
resource "google_project_iam_binding" "logging_admin" {
  project    = var.project
  role       = var.logging_admin_role
  depends_on = [google_service_account.logging_service_account]

  members = [
    "serviceAccount:${google_service_account.logging_service_account.email}"
  ]
}

# Add monitoring metric writer role to service account
resource "google_project_iam_binding" "monitoring_metric_writer" {
  project    = var.project
  role       = var.logging_monitoring_metric_writer_role
  depends_on = [google_service_account.logging_service_account]

  members = [
    "serviceAccount:${google_service_account.logging_service_account.email}"
  ]
}

resource "google_service_account" "pubsub_publisher" {
  account_id   = var.pubsub_publisher_account_id
  display_name = var.pubsub_publisher_display_name
}

resource "google_project_iam_binding" "publisher_role" {
  project    = var.project
  role       = var.pubsub_publisher_publisher_role
  depends_on = [google_service_account.pubsub_publisher]

  members = [
    "serviceAccount:${google_service_account.pubsub_publisher.email}"
  ]
}

resource "google_service_account_key" "pubsub_publisher_key" {
  service_account_id = google_service_account.pubsub_publisher.id
}

#VM Instance for webapp
resource "google_compute_instance" "webapp_instance" {
  name         = var.compute_instance_name
  machine_type = var.instance_machine_type
  zone         = var.instance_zone
  tags         = var.tags
  depends_on   = [google_project_iam_binding.logging_admin, google_project_iam_binding.monitoring_metric_writer]

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

sudo echo "spring.datasource.url=jdbc:mysql://${google_sql_database_instance.database_instance.first_ip_address}:3306/${google_sql_database.database.name}?createDatabaseIfNotExist=true" >> /opt/db.properties
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

sudo touch /opt/pubsub-service-account-key.json
sudo echo '${base64decode(google_service_account_key.pubsub_publisher_key.private_key)}' >> /opt/pubsub-service-account-key.json
EOF
  }
  service_account {
    email  = google_service_account.logging_service_account.email
    scopes = var.compute_instance_service_account_scopes
  }
}

resource "google_dns_record_set" "webapp_a_record" {
  name = var.dns_a_record_name
  type = var.dns_a_record_type
  ttl = var.dns_a_record_ttl
  managed_zone = var.dns_a_record_managed_zone
  rrdatas = [google_compute_address.lb_address.address]
}

# Serverless Function

# Creating topic for pub-sub
resource "google_pubsub_topic" "webapp_topic" {
  name = var.webapp_topic_name
  message_retention_duration = var.webapp_topic_retention
}

# Creating a subscription for the topic 
resource "google_pubsub_subscription" "webapp_topic_subscription" {
  name   = var.webapp_topic_subscription_name
  topic  = google_pubsub_topic.webapp_topic.name
  depends_on = [ google_pubsub_topic.webapp_topic ]
}

resource "google_cloudfunctions2_function" "cloud_function" {
  name        = var.cloud_function_name
  location = var.region
  description = var.cloud_function_description
  depends_on = [ google_pubsub_topic.webapp_topic, google_sql_database_instance.database_instance, 
                  google_sql_user.users, google_sql_database.database, google_vpc_access_connector.cloud_function_connector, 
                  google_service_account.serverless_account]

  build_config {
    runtime = var.cloud_function_run_time
    entry_point = var.cloud_function_entry_point
    source {
      storage_source {
        bucket = var.cloud_function_source_bucket
        object = var.cloud_function_source_object
      }
    }
  }
  service_config {
    available_memory   = var.cloud_function_memory
    timeout_seconds = var.cloud_function_timeout
    max_instance_count = var.cloud_function_instance_count
    vpc_connector = google_vpc_access_connector.cloud_function_connector.id
    environment_variables = {
      # SMTP Env variables
      SMTP_HOST = var.cloud_function_env_smtp_host
      SMTP_PORT = var.cloud_function_env_smtp_port
      SMTP_USERNAME = var.cloud_function_env_smtp_username
      SMTP_PASSWORD = var.cloud_function_env_smtp_password
      SMTP_VERIFICATION_LINK = var.cloud_function_env_smtp_verification_link
      SMTP_FROM_EMAIL = var.cloud_function_env_smtp_email

      # MYSQL Env variables
      DB_HOST_IP = google_sql_database_instance.database_instance.first_ip_address
      DB_USER = google_sql_user.users.name
      DB_PASSWORD = google_sql_user.users.password
      DB_TABLE = var.cloud_function_env_db_table
      DB_DATABASE = google_sql_database.database.name
    }
  }

  event_trigger  {
      event_type= var.cloud_function_event_trigger_type
      pubsub_topic = google_pubsub_topic.webapp_topic.id
      service_account_email = google_service_account.serverless_account.email
  }
}

# IAM entry for all users to invoke the function
resource "google_service_account" "serverless_account" {
  account_id   = var.serverless_account_id
  display_name = var.serverless_display_name
}

resource "google_project_iam_binding" "serverless_cloud_function_developer" {
  project    = var.project
  role       = var.serverless_cloud_function_developer_role
  depends_on = [google_service_account.serverless_account]

  members = [
    "serviceAccount:${google_service_account.serverless_account.email}"
  ]
}

resource "google_project_iam_binding" "serverless_cloud_sql_client" {
  project    = var.project
  role       = var.serverless_cloud_SQL_Client
  depends_on = [google_service_account.serverless_account]

  members = [
    "serviceAccount:${google_service_account.serverless_account.email}"
  ]
}

# VPC Serverless Connector 
resource "google_compute_subnetwork" "mysql_connection" {
  name          = var.mysql_connection_subnet_name
  ip_cidr_range = var.mysql_connection_subnet_ip_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_vpc_access_connector" "cloud_function_connector" {
  name          = var.vpc_access_connector_name
  depends_on = [ google_compute_subnetwork.mysql_connection ]
  subnet {
    name = google_compute_subnetwork.mysql_connection.name
  }
  machine_type = var.vpc_access_connector_machine_type
}

# ---------------------------------------   Load Balancer and Autoscaler -----------------------------

# # Service accout for template creation ---------------------------------------------------------------
# resource "google_service_account" "template" {
#   account_id   = "instance-template-generator"
#   display_name = "Instance template generator"
# }

# resource "google_project_iam_binding" "publisher_role_template" {
#   project    = var.project
#   role       = var.pubsub_publisher_publisher_role

#   members = [
#     "serviceAccount:${google_service_account.template.email}"
#   ]
# }

#  Regional instance template ------------------------------------------------------------------------
resource "google_compute_region_instance_template" "csye6225_template" {
  name = "csye6225-template"
  region = var.region

  machine_type = "e2-medium"
  can_ip_forward = false

  disk {
    source_image = var.instance_app_image_family
    auto_delete = true
    boot = true

  }

  network_interface {
    network = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.webapp_subnet.name
  }

  service_account {
    email = google_service_account.logging_service_account.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = <<-EOF
#!/bin/bash

if [ ! -f "/opt/db.properties" ] 
then
sudo touch /opt/db.properties

sudo echo "spring.datasource.url=jdbc:mysql://${google_sql_database_instance.database_instance.first_ip_address}:3306/${google_sql_database.database.name}?createDatabaseIfNotExist=true" >> /opt/db.properties
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
sudo touch /opt/pubsub-service-account-key.json
sudo echo '${base64decode(google_service_account_key.pubsub_publisher_key.private_key)}' >> /opt/pubsub-service-account-key.json
EOF
  }

  tags = var.tags
  
}

# Creating  a health check for the instance ------------------------------------------------------
resource "google_compute_region_health_check" "webapp_health_check" {

  name = "webapp-health-check"

  timeout_sec = 20
  check_interval_sec = 20
  healthy_threshold = 2
  unhealthy_threshold = 5

  http_health_check {
    port = 8080
    request_path = "/healthz"
    port_specification = "USE_FIXED_PORT"
  }

  log_config {
    enable = true
  }
  
}

# Creating a regional autoscaler ---------------------------------------------------------------
resource "google_compute_region_autoscaler" "webapp_autoscaler" {

  name = "webapp-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.csye6225_mig.id

  # Autoscaling when CPU Util = 5%
  autoscaling_policy {
    max_replicas = 5
    min_replicas = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.05
    }
  }

}

# Creaing target pool
resource "google_compute_target_pool" "target_pool" {
  name = "target-pool"
  
}

# Creating the Instance Group Manager
resource "google_compute_region_instance_group_manager" "csye6225_mig" {
  name = "csye6225-group-manager"
  region = var.region

  version {
    instance_template = google_compute_region_instance_template.csye6225_template.id
    name = "primary"
  }

  target_pools = [google_compute_target_pool.target_pool.id]
  base_instance_name = "webapp"

  named_port {
    name = "http"
    port = 8080
  }

}

# Creating an External Application Load Balancer --------------------------------------------

# Create a VPC proxy-only subnet
resource "google_compute_subnetwork" "proxy_only" {
  name          = "proxy-only-subnet"
  ip_cidr_range = "10.129.0.0/23"
  network       = google_compute_network.vpc.id
  purpose       = "REGIONAL_MANAGED_PROXY"
  region        = var.region
  role          = "ACTIVE"
}
# Reserve an IP address
resource "google_compute_address" "lb_address" {
  name         = "lb-address"
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
  region       = var.region
}

# Create firewall rule
resource "google_compute_firewall" "lb_default" {
  name = "fw-allow-health-check"
  allow {
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc.id
  priority      = 900
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["load-balanced-backend"]
}

resource "google_compute_firewall" "allow_proxy" {
  name = "fw-allow-proxies"
  allow {
    ports    = ["443"]
    protocol = "tcp"
  }
  allow {
    ports    = ["80"]
    protocol = "tcp"
  }
  allow {
    ports    = ["8080"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc.id
  priority      = 900
  source_ranges = ["10.129.0.0/23"]
  target_tags   = ["load-balanced-backend"]
}
# Creating an Backend Service
resource "google_compute_region_backend_service" "webapp_backend" {
  name = "webapp-backend"
  region = var.region
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks = [google_compute_region_health_check.webapp_health_check.id]

  protocol = "HTTP"

  backend {
    group = google_compute_region_instance_group_manager.csye6225_mig.instance_group
    balancing_mode = "UTILIZATION"
    capacity_scaler = 1.0
  }

}

# Creating a URL Map
resource "google_compute_region_url_map" "lb_url_map" {
  name = "lb-url-map"
  region = var.region
  default_service = google_compute_region_backend_service.webapp_backend.id
  
}

# Creating a target HTTP proxy
resource "google_compute_region_target_http_proxy" "lb_target_proxy" {
  name = "lb-target-proxy"
  region = var.region
  url_map = google_compute_region_url_map.lb_url_map.id
  # ssl_certificates = [ google_compute_managed_ssl_certificate.lb_default.id ]
  # depends_on = [ google_compute_managed_ssl_certificate.lb_default ]
}

# Creating a forwarding rule
resource "google_compute_forwarding_rule" "lb_forwarding_rule"{
  name = "lb-forwarding-rule"
  provider = google
  project = var.project
  region = var.region
  depends_on = [ google_compute_subnetwork.proxy_only ]

  ip_protocol = "TCP"
  port_range = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target = google_compute_region_target_http_proxy.lb_target_proxy.id
  network = google_compute_network.vpc.id
  ip_address = google_compute_address.lb_address.id
  network_tier = "STANDARD"

}

# Output IP of load balancer
output "load_balancer_IP" {
  value = google_compute_address.lb_address.address
  
}

# Certificate---------------------------------
# resource "google_compute_managed_ssl_certificate" "lb_default" {
#   name     = "test-cert-abhinav"
#   project = var.project
#   managed {
#     domains = ["choudhary-abhinav.me."]
#   }
# }