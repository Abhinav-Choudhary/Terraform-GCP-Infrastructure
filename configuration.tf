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
  name                     = var.webapp_subnet_name
  network                  = google_compute_network.vpc.name
  ip_cidr_range            = var.ip_cidr_range_webapp
  region                   = var.region
  project                  = var.project
  private_ip_google_access = var.private_ip_google_access
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

# resource "google_service_account" "sql_service_account" {
#   account_id   = "cloud-sql-service-account"
#   display_name = "Cloud sql service account"
# }

# # Add logging admin role to service account
# resource "google_project_iam_binding" "clous_sql_admin" {
#   project    = var.project
#   role       = "roles/cloudsql.admin"
#   depends_on = [google_service_account.sql_service_account]

#   members = [
#     "serviceAccount:${google_service_account.sql_service_account.email}"
#   ]
# }

# Setup CloudSQL database
resource "google_sql_database_instance" "database_instance" {
  name                = "${var.sql_database_instance_name}-${random_id.db_instance_name_suffix.hex}"
  database_version    = var.sql_database_instance_version
  region              = var.region
  deletion_protection = var.sql_database_instance_deletion_protection
  encryption_key_name = google_kms_crypto_key.sql_key.id
  depends_on          = [google_service_networking_connection.webapp_service_networking_connection, google_kms_crypto_key.sql_key, google_kms_crypto_key_iam_binding.crypto_sql_key]
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

resource "google_dns_record_set" "webapp_a_record" {
  name         = var.dns_a_record_name
  type         = var.dns_a_record_type
  ttl          = var.dns_a_record_ttl
  managed_zone = var.dns_a_record_managed_zone
  rrdatas      = [google_compute_address.lb_address.address]
}

# Serverless Function

# Creating topic for pub-sub
resource "google_pubsub_topic" "webapp_topic" {
  name                       = var.webapp_topic_name
  message_retention_duration = var.webapp_topic_retention
}

# Creating a subscription for the topic 
resource "google_pubsub_subscription" "webapp_topic_subscription" {
  name       = var.webapp_topic_subscription_name
  topic      = google_pubsub_topic.webapp_topic.name
  depends_on = [google_pubsub_topic.webapp_topic]
}

resource "google_cloudfunctions2_function" "cloud_function" {
  name        = var.cloud_function_name
  location    = var.region
  description = var.cloud_function_description
  depends_on = [google_pubsub_topic.webapp_topic, google_sql_database_instance.database_instance,
    google_sql_user.users, google_sql_database.database, google_vpc_access_connector.cloud_function_connector,
  google_service_account.serverless_account]

  build_config {
    runtime     = var.cloud_function_run_time
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
    timeout_seconds    = var.cloud_function_timeout
    max_instance_count = var.cloud_function_instance_count
    vpc_connector      = google_vpc_access_connector.cloud_function_connector.id
    environment_variables = {
      # SMTP Env variables
      SMTP_HOST              = var.cloud_function_env_smtp_host
      SMTP_PORT              = var.cloud_function_env_smtp_port
      SMTP_USERNAME          = var.cloud_function_env_smtp_username
      SMTP_PASSWORD          = var.cloud_function_env_smtp_password
      SMTP_VERIFICATION_LINK = var.cloud_function_env_smtp_verification_link
      SMTP_FROM_EMAIL        = var.cloud_function_env_smtp_email

      # MYSQL Env variables
      DB_HOST_IP  = google_sql_database_instance.database_instance.first_ip_address
      DB_USER     = google_sql_user.users.name
      DB_PASSWORD = google_sql_user.users.password
      DB_TABLE    = var.cloud_function_env_db_table
      DB_DATABASE = google_sql_database.database.name
    }
  }

  event_trigger {
    event_type            = var.cloud_function_event_trigger_type
    pubsub_topic          = google_pubsub_topic.webapp_topic.id
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
  name       = var.vpc_access_connector_name
  depends_on = [google_compute_subnetwork.mysql_connection]
  subnet {
    name = google_compute_subnetwork.mysql_connection.name
  }
  machine_type = var.vpc_access_connector_machine_type
}

#  Regional instance template
resource "google_compute_region_instance_template" "csye6225_template" {
  name           = var.compute_instance_name
  region         = var.region
  machine_type   = var.instance_machine_type
  can_ip_forward = var.compute_instance_can_ip_forward
  tags           = var.tags
  depends_on     = [google_project_iam_binding.logging_admin, google_project_iam_binding.monitoring_metric_writer, google_kms_crypto_key.vm_key]

  disk {
    source_image = var.instance_app_image_family
    auto_delete  = var.compute_instance_auto_delete
    boot         = var.compute_instance_boot
    disk_encryption_key {
      kms_key_self_link = google_kms_crypto_key.vm_key.id
    }
  }

  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.webapp_subnet.name
  }

  service_account {
    email  = google_service_account.logging_service_account.email
    scopes = var.compute_instance_service_account_scopes
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

sudo echo '${google_service_account_key.pubsub_publisher_key.private_key}'
EOF
  }
}

# Health Check
resource "google_compute_region_health_check" "webapp_health_check" {

  name = var.health_check_name

  timeout_sec         = var.health_check_timeout_sec
  check_interval_sec  = var.health_check_check_interval_sec
  healthy_threshold   = var.health_check_healthy_threshold
  unhealthy_threshold = var.health_check_unhealthy_threshold

  http_health_check {
    port               = var.health_check_http_port
    request_path       = var.health_check_http_request_path
    port_specification = var.health_check_http_port_specification
  }

  log_config {
    enable = var.health_check_log_enabled
  }
}

# Regional Autoscaler
resource "google_compute_region_autoscaler" "webapp_autoscaler" {

  name   = var.autoscaler_name
  region = var.region
  target = google_compute_region_instance_group_manager.csye6225_mig.id
  autoscaling_policy {
    max_replicas    = var.autoscaler_max_replica
    min_replicas    = var.autoscaler_min_replica
    cooldown_period = var.autoscaler_cooldown_period

    cpu_utilization {
      target = var.autoscaler_cpu_utilization
    }
  }
}

# Creaing target pool
resource "google_compute_target_pool" "target_pool" {
  name = var.targetpool_name
}

# Creating the Instance Group Manager
resource "google_compute_region_instance_group_manager" "csye6225_mig" {
  name   = var.mig_name
  region = var.region

  version {
    instance_template = google_compute_region_instance_template.csye6225_template.id
    name              = var.mig_version_name
  }

  target_pools       = [google_compute_target_pool.target_pool.id]
  base_instance_name = var.mig_base_instance_name

  named_port {
    name = var.mig_named_port_name
    port = var.mig_named_port
  }

  auto_healing_policies {
    health_check      = google_compute_region_health_check.webapp_health_check.id
    initial_delay_sec = 120
  }
}

# External Application Load Balancer

# VPC proxy-only subnet
resource "google_compute_subnetwork" "proxy_only_subnet" {
  name          = var.proxy_subnet_name
  ip_cidr_range = var.proxy_subnet_ip_cidr
  network       = google_compute_network.vpc.id
  purpose       = var.proxy_subnet_purpose
  region        = var.region
  role          = var.proxy_subnet_role
}
# Reserve an IP address
resource "google_compute_address" "lb_address" {
  name         = var.lb_address_name
  address_type = var.lb_address_type
  network_tier = var.lb_address_Network_tier
  region       = var.region
}
# Creating an Backend Service
resource "google_compute_region_backend_service" "webapp_backend" {
  name                  = var.backend_name
  region                = var.region
  load_balancing_scheme = var.backend_load_balancing_scheme
  health_checks         = [google_compute_region_health_check.webapp_health_check.id]

  protocol = var.backend_protocol

  backend {
    group           = google_compute_region_instance_group_manager.csye6225_mig.instance_group
    balancing_mode  = var.backend_balancing_mode
    capacity_scaler = var.backend_capacity_scaler
  }
}

# Creating a URL Map
resource "google_compute_region_url_map" "lb_url_map" {
  name            = var.lb_url_name
  region          = var.region
  default_service = google_compute_region_backend_service.webapp_backend.id
}

# Creating a target HTTP proxy
resource "google_compute_region_target_https_proxy" "lb_target_proxy" {
  name             = var.lb_target_proxy_name
  region           = var.region
  url_map          = google_compute_region_url_map.lb_url_map.id
  ssl_certificates = [google_compute_region_ssl_certificate.namecheap_cert.id]
}

# Creating a forwarding rule
resource "google_compute_forwarding_rule" "lb_forwarding_rule" {
  name       = var.lb_forwarding_rule_name
  provider   = google
  project    = var.project
  region     = var.region
  depends_on = [google_compute_subnetwork.proxy_only_subnet]

  ip_protocol           = var.lb_forwarding_rule_protocol
  port_range            = var.lb_forwarding_rule_port_range
  load_balancing_scheme = var.lb_forwarding_rule_balancing_scheme
  target                = google_compute_region_target_https_proxy.lb_target_proxy.id
  network               = google_compute_network.vpc.id
  ip_address            = google_compute_address.lb_address.id
  network_tier          = var.lb_forwarding_rule_network_tier
}

# Certificate
resource "google_compute_region_ssl_certificate" "namecheap_cert" {
  region      = var.region
  name        = var.ssl_cert_name
  private_key = file(var.ssl_cert_private_key)
  certificate = file(var.ssl_cert_certificate)
}

# Key Ring
resource "google_kms_key_ring" "csye6225_abhinav_keyring" {
  name     = "key-ring-${random_id.db_instance_name_suffix.hex}"
  location = var.region
}

# Keys
resource "google_kms_crypto_key" "vm_key" {
  name            = "vm-key-${random_id.db_instance_name_suffix.hex}"
  key_ring        = google_kms_key_ring.csye6225_abhinav_keyring.id
  rotation_period = var.crypto_key_rotation_period
  depends_on      = [google_kms_key_ring.csye6225_abhinav_keyring]
}

resource "google_kms_crypto_key_iam_policy" "vm_key_policy" {
  crypto_key_id = google_kms_crypto_key.vm_key.id
  policy_data   = data.google_iam_policy.key_policy.policy_data
  depends_on    = [google_kms_crypto_key.vm_key]
}

resource "google_kms_crypto_key" "sql_key" {
  name            = "sql-key-${random_id.db_instance_name_suffix.hex}"
  key_ring        = google_kms_key_ring.csye6225_abhinav_keyring.id
  rotation_period = var.crypto_key_rotation_period
  depends_on      = [google_kms_crypto_key_iam_policy.vm_key_policy, google_kms_key_ring.csye6225_abhinav_keyring]
}

resource "google_kms_crypto_key" "bucket_key" {
  name            = "bucket-key-${random_id.db_instance_name_suffix.hex}"
  key_ring        = google_kms_key_ring.csye6225_abhinav_keyring.id
  rotation_period = var.crypto_key_rotation_period
  depends_on      = [google_kms_key_ring.csye6225_abhinav_keyring]
}

data "google_iam_policy" "key_policy" {
  binding {
    members = [
      "serviceAccount:${var.compute_system_service_account}"
    ]
    role = var.cloud_key_encrypter_decrypter_role
  }
}

resource "google_kms_crypto_key_iam_policy" "cloudsql_key_policy" {
  crypto_key_id = google_kms_crypto_key.sql_key.id
  policy_data   = data.google_iam_policy.key_policy.policy_data
  depends_on    = [google_kms_crypto_key.sql_key]
}

resource "google_kms_crypto_key_iam_binding" "crypto_sql_key" {
  provider      = google
  crypto_key_id = google_kms_crypto_key.sql_key.id
  role          = var.cloud_key_encrypter_decrypter_role
  depends_on    = [google_kms_crypto_key_iam_policy.cloudsql_key_policy]

  members = [
    "serviceAccount:${var.compute_system_sql_account}",
  ]
}

data "google_storage_project_service_account" "gcs_account" {
}

resource "google_kms_crypto_key_iam_binding" "bucket_binding" {
  crypto_key_id = google_kms_crypto_key.bucket_key.id
  role          = var.cloud_key_encrypter_decrypter_role

  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}

resource "null_resource" "bucket_update" {

  depends_on = [google_kms_crypto_key_iam_binding.bucket_binding]
  provisioner "local-exec" {
    command = "gcloud storage buckets update gs://${var.cloud_function_source_bucket} --default-encryption-key=${google_kms_crypto_key.bucket_key.id}"
  }
}

# Outputs
output "load_balancer_IP" {
  value = google_compute_address.lb_address.address
}

output "sql_instance" {
  value = google_sql_database_instance.database_instance.first_ip_address
}

output "sql_database" {
  value = google_sql_database.database.name
}

output "sql_user" {
  value = google_sql_user.users.name
}

output "sql_password" {
  value     = google_sql_user.users.password
  sensitive = true
}

output "pubsub_service_account_private_key" {
  value     = google_service_account_key.pubsub_publisher_key.private_key
  sensitive = true
}