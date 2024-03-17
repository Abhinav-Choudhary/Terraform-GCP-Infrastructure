variable "project" {
  type        = string
  description = "GCP Project ID"
  default     = "csye6225-abhinav-dev"
}

variable "region" {
  type        = string
  description = "GCP Region"
  default     = "us-east1"
}

variable "network_name" {
  type        = string
  description = "Network Name"
  default     = "abhinav-vpc"
}

variable "routing_mode" {
  type        = string
  description = "Set routing mode to global or regional"
  default     = "REGIONAL"
}

variable "auto_create_subnet" {
  type        = bool
  description = "Specify whether default subnets should be autocreated"
  default     = false
}

variable "delete_default_routes" {
  type        = bool
  description = "Specify whether default routes should be created"
  default     = true
}

variable "ip_cidr_range_webapp" {
  type        = string
  description = "IP CIDR range for subnet webapp"
  default     = "10.0.1.0/24"
}

variable "ip_cidr_range_db" {
  type        = string
  description = "IP CIDR range for subnet db"
  default     = "10.0.2.0/24"
}

variable "destination_range" {
  type        = string
  description = "The destination range of outgoing packets that this route applies to. Only IPv4 is supported."
  default     = "0.0.0.0/0"
}

variable "webapp_subnet_name" {
  type        = string
  description = "Name for webapp subnet"
  default     = "webapp"
}

variable "db_subnet_name" {
  type        = string
  description = "Name for db subnet"
  default     = "db"
}

variable "webapp_route_name" {
  type        = string
  description = "Name for webapp route"
  default     = "webapp-route"
}

variable "internet_gateway" {
  type        = string
  description = "Set the default internet gateway"
  default     = "default-internet-gateway"
}

variable "tags" {
  type        = list(string)
  description = "Tags for http traffic"
  default     = ["webapp"]
}

variable "firewall_name" {
  type        = string
  description = "Name for http firewall"
  default     = "webapp-firewall"
}

variable "firewall_deny_name" {
  type        = string
  description = "Name for http firewall"
  default     = "webapp-firewall-deny"
}

variable "firewall_tcp_allow_ports" {
  type        = list(string)
  description = "Set which ports http firewall listens to"
  default     = ["8080"]
}

variable "firewall_allow_priority" {
  type        = number
  description = "Set priority for allow firewall rule"
  default     = 900
}

variable "http_protocol" {
  type        = string
  description = "protocol for http requests"
  default     = "tcp"
}

variable "firewall_source_ranges" {
  type        = list(string)
  description = "Source ranges for firewall rule"
  default     = ["0.0.0.0/0"]
}

variable "compute_address_name" {
  type        = string
  description = "Name for compute address"
  default     = "ipv4-address"
}

variable "compute_instance_name" {
  type        = string
  description = "Name for VM Instance"
  default     = "csye6225-instance"
}

variable "instance_machine_type" {
  type        = string
  description = "Set machine type for VM Instance"
  default     = "e2-small"
}

variable "instance_zone" {
  type        = string
  description = "Set the zone for VM Instance"
  default     = "us-east1-b"
}

variable "instance_app_image_family" {
  type        = string
  description = "Set instance image family"
  default     = "csye6225-app-image"
}

variable "instance_disk_size" {
  type        = number
  description = "Set default boot disk size for VM Instance"
  default     = 100
}

variable "instance_disk_type" {
  type        = string
  description = "Set default boot disk type for VM Instance"
  default     = "pd-balanced"
}

variable "private_ip_google_access" {
  type        = bool
  description = "Set value for private_ip_google_access"
  default     = true
}

variable "global_address_name" {
  type        = string
  description = "Name for google_compute_global_address"
  default     = "global-psconnect-ip"
}

variable "global_address_type" {
  type        = string
  description = "Address type for google_compute_global_address"
  default     = "INTERNAL"
}

variable "global_address_purpose" {
  type        = string
  description = "Purpose for google_compute_global_address"
  default     = "VPC_PEERING"
}

variable "global_address_prefix_length" {
  type        = number
  description = "Prefix length for google_compute_global_address"
  default     = 16
}

variable "service_networking_connection_service" {
  type        = string
  description = "Service for google_service_networking_connection"
  default     = "servicenetworking.googleapis.com"
}

variable "db_instance_name_suffix_length" {
  type        = number
  description = "Byte Length for random_id"
  default     = 4
}

variable "sql_database_instance_name" {
  type        = string
  description = "Name for google_sql_database_instance"
  default     = "webapp-instance"
}

variable "sql_database_instance_version" {
  type        = string
  description = "MySQL version for google_sql_database_instance"
  default     = "MYSQL_8_0"
}

variable "sql_database_instance_deletion_protection" {
  type        = bool
  description = "Set deletion protection for google_sql_database_instance"
  default     = false
}

variable "sql_database_instance_tier" {
  type        = string
  description = "Tier for google_sql_database_instance"
  default     = "db-f1-micro"
}

variable "sql_database_instance_availability_type" {
  type        = string
  description = "Availability type for google_sql_database_instance"
  default     = "REGIONAL"
}

variable "sql_database_instance_disk_type" {
  type        = string
  description = "disk type for google_sql_database_instance"
  default     = "pd-ssd"
}

variable "sql_database_instance_disk_size" {
  type        = string
  description = "Disk size for google_sql_database_instance"
  default     = "100"
}

variable "sql_database_instance_disk_autoresize" {
  type        = bool
  description = "Auto resize for google_sql_database_instance"
  default     = false
}

variable "sql_database_instance_ipv4_enabled" {
  type        = bool
  description = "Set Ipv4 for google_sql_database_instance"
  default     = false
}

variable "sql_database_instance_enable_private_path" {
  type        = bool
  description = "Set enable private path for google_sql_database_instance"
  default     = true
}

variable "sql_database_instance_binary_logs" {
  type        = bool
  description = "Set Binary Logs for google_sql_database_instance"
  default     = true
}

variable "sql_database_instance_backup_enabled" {
  type        = bool
  description = "Set whether to enable backup for google_sql_database_instance"
  default     = true
}

variable "sql_database_name" {
  type        = string
  description = "Name for google_sql_database"
  default     = "webapp"
}

variable "password_length" {
  type        = number
  description = "Length for random password"
  default     = 16
}

variable "password_special" {
  type        = bool
  description = "Set whether to use special characters for random password"
  default     = true
}

variable "password_override_special" {
  type        = string
  description = "Override special for random password"
  default     = "!#$%&*()-_=+[]{}<>:?"
}

variable "sql_user_name" {
  type        = string
  description = "Name for CloudSQL user"
  default     = "webapp"
}

variable "logging_account_id" {
  type        = string
  description = "Name for Logging service account account id"
  default     = "logging-service-account"
}

variable "logging_display_name" {
  type        = string
  description = "Name for Logging service account display name"
  default     = "Logging Service Account"
}

variable "logging_admin_role" {
  type        = string
  description = "Name for Logging service account admin role"
  default     = "roles/logging.admin"
}

variable "logging_monitoring_metric_writer_role" {
  type        = string
  description = "Name for Logging service account monitoring metric writer role"
  default     = "roles/monitoring.metricWriter"
}

variable "compute_instance_service_account_scopes" {
  type        = list(string)
  description = "Scopes for compute instance service account"
  default     = ["cloud-platform"]
}