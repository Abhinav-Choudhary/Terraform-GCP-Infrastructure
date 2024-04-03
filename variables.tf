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

variable "compute_instance_can_ip_forward" {
  type        = bool
  description = "Enable IP forward for compute instance"
  default     = false
}

variable "compute_instance_auto_delete" {
  type        = bool
  description = "Enable Auto Delete for compute instance"
  default     = true
}

variable "compute_instance_boot" {
  type        = bool
  description = "Enable Boot for compute instance"
  default     = true
}

variable "instance_machine_type" {
  type        = string
  description = "Set machine type for VM Instance"
  default     = "e2-medium"
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
  default     = "!#%&*-_=+[]{}<>:?"
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

variable "dns_a_record_name" {
  type        = string
  description = "Domain name for A record"
  default     = "choudhary-abhinav.me."
}

variable "dns_a_record_type" {
  type        = string
  description = "A record type"
  default     = "A"
}

variable "dns_a_record_ttl" {
  type        = number
  description = "Time to live (in seconds) for domain dns"
  default     = 300
}

variable "dns_a_record_managed_zone" {
  type        = string
  description = "DNS name for zone"
  default     = "choudhary-abhinav"
}

variable "pubsub_publisher_account_id" {
  type        = string
  description = "Account Id for Pub/Sub service account"
  default     = "pubsub-publisher"
}

variable "pubsub_publisher_display_name" {
  type        = string
  description = "Display name for Pub/Sub service account"
  default     = "PubSub Publisher"
}

variable "pubsub_publisher_publisher_role" {
  type        = string
  description = "Publisher role for Pub/Sub service account"
  default     = "roles/pubsub.publisher"
}

variable "webapp_topic_name" {
  type        = string
  description = "Name for Webapp GCP topic"
  default     = "verify_email"
}

variable "webapp_topic_retention" {
  type        = string
  description = "Retention for Webapp GCP topic"
  default     = "604800s"
}

variable "webapp_topic_subscription_name" {
  type        = string
  description = "Name for Webapp GCP topic Subscription"
  default     = "subscriber"
}

variable "cloud_function_name" {
  type        = string
  description = "Name for Webapp GCP cloud function"
  default     = "email-lambda-function"
}

variable "cloud_function_description" {
  type        = string
  description = "Description for Webapp GCP cloud function"
  default     = "Function to handle user verification email processing"
}

variable "cloud_function_run_time" {
  type        = string
  description = "Run time for Webapp GCP cloud function"
  default     = "python311"
}

variable "cloud_function_entry_point" {
  type        = string
  description = "Entry point for Webapp GCP cloud function"
  default     = "lambda_function"
}

variable "cloud_function_source_bucket" {
  type        = string
  description = "Source bucket for Webapp GCP cloud function"
  default     = "serverless-function-abhinav"
}

variable "cloud_function_source_object" {
  type        = string
  description = "Source bucket object for Webapp GCP cloud function"
  default     = "index.zip"
}

variable "cloud_function_memory" {
  type        = string
  description = "Availale memory object for Webapp GCP cloud function"
  default     = "128Mi"
}

variable "cloud_function_timeout" {
  type        = number
  description = "Timeout (in seconds) for Webapp GCP cloud function"
  default     = 60
}

variable "cloud_function_instance_count" {
  type        = number
  description = "Instance count for Webapp GCP cloud function"
  default     = 1
}

variable "cloud_function_env_smtp_host" {
  type        = string
  description = "SMTP Host Env variable for Webapp GCP cloud function"
  default     = "smtp.mailgun.org"
}

variable "cloud_function_env_smtp_port" {
  type        = number
  description = "SMTP Port Env variable for Webapp GCP cloud function"
  default     = 587
}

variable "cloud_function_env_smtp_username" {
  type        = string
  description = "SMTP Username Env variable for Webapp GCP cloud function"
  default     = "postmaster@mail.choudhary-abhinav.me"
}

variable "cloud_function_env_smtp_password" {
  type        = string
  description = "SMTP Password Env variable for Webapp GCP cloud function"
  default     = "df156c1458e29cddb1bf9bed1fdef297-f68a26c9-5ba9a9f5"
}

variable "cloud_function_env_smtp_verification_link" {
  type        = string
  description = "SMTP Verification Link Env variable for Webapp GCP cloud function"
  default     = "https://choudhary-abhinav.me/v1/verify"
}

variable "cloud_function_env_smtp_email" {
  type        = string
  description = "SMTP Email Env variable for Webapp GCP cloud function"
  default     = "no-reply@choudhary-abhinav.me"
}

variable "cloud_function_env_db_table" {
  type        = string
  description = "DB Table Env variable for Webapp GCP cloud function"
  default     = "verify_user"
}

variable "cloud_function_event_trigger_type" {
  type        = string
  description = "Event Trigger Type for Webapp GCP cloud function"
  default     = "google.cloud.pubsub.topic.v1.messagePublished"
}

variable "serverless_account_id" {
  type        = string
  description = "Account Id for Serverless service account"
  default     = "serverless-publisher"
}

variable "serverless_display_name" {
  type        = string
  description = "Display name for Serverless service account"
  default     = "Serverless Publisher"
}

variable "serverless_cloud_function_developer_role" {
  type        = string
  description = "Cloud Functiond Developer role for Serverless service account"
  default     = "roles/cloudfunctions.developer"
}

variable "serverless_cloud_SQL_Client" {
  type        = string
  description = "Cloud SQL Client role for Serverless service account"
  default     = "roles/cloudsql.client"
}

variable "mysql_connection_subnet_name" {
  type        = string
  description = "MySQL connection subnet name"
  default     = "mysql-connection"
}

variable "mysql_connection_subnet_ip_cidr" {
  type        = string
  description = "MySQL connection subnet Ip CIDR range"
  default     = "10.8.0.0/28"
}

variable "vpc_access_connector_name" {
  type        = string
  description = "VPC access connector name"
  default     = "vpc-connector"
}

variable "vpc_access_connector_machine_type" {
  type        = string
  description = "VPC access connector Machine Type"
  default     = "e2-standard-4"
}

variable "health_check_name" {
  type        = string
  description = "Name for Health Check"
  default     = "webapp-health-check"
}

variable "health_check_timeout_sec" {
  type        = number
  description = "Timeout (seconds) for Health Check"
  default     = 20
}

variable "health_check_check_interval_sec" {
  type        = number
  description = "Check Interval (seconds) for Health Check"
  default     = 20
}

variable "health_check_healthy_threshold" {
  type        = number
  description = "Healthy Threshold for Health Check"
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  type        = number
  description = "Unhealthy Threshold for Health Check"
  default     = 5
}

variable "health_check_http_port" {
  type        = number
  description = "Port for Health Check http"
  default     = 8080
}

variable "health_check_http_request_path" {
  type        = string
  description = "Request Path for Health Check http"
  default     = "/healthz"
}

variable "health_check_http_port_specification" {
  type        = string
  description = "Port Specification for Health Check http"
  default     = "USE_FIXED_PORT"
}

variable "health_check_log_enabled" {
  type        = bool
  description = "Enable Logs for Health Check http"
  default     = true
}

variable "autoscaler_name" {
  type        = string
  description = "Name for Autoscaler"
  default     = "webapp-autoscaler"
}

variable "autoscaler_max_replica" {
  type        = number
  description = "Max Replica for Autoscaler"
  default     = 6
}

variable "autoscaler_min_replica" {
  type        = number
  description = "Min Replica for Autoscaler"
  default     = 3
}

variable "autoscaler_cooldown_period" {
  type        = number
  description = "Cooldown Period for Autoscaler"
  default     = 60
}

variable "autoscaler_cpu_utilization" {
  type        = number
  description = "CPU Utilization for Autoscaler"
  default     = 0.05
}

variable "targetpool_name" {
  type        = string
  description = "Name for Target Pool"
  default     = "webapp-target-pool"
}

variable "mig_name" {
  type        = string
  description = "Name for MIG"
  default     = "webapp-group-manager"
}

variable "mig_version_name" {
  type        = string
  description = "Name for instance template version in MIG"
  default     = "primary"
}

variable "mig_base_instance_name" {
  type        = string
  description = "Name for base instance in MIG"
  default     = "webapp"
}

variable "mig_named_port_name" {
  type        = string
  description = "Name for named port in MIG"
  default     = "http"
}

variable "mig_named_port" {
  type        = number
  description = "Port for named port in MIG"
  default     = 8080
}

variable "proxy_subnet_name" {
  type        = string
  description = "Name for proxy subnet"
  default     = "proxy-only-subnet"
}

variable "proxy_subnet_ip_cidr" {
  type        = string
  description = "Ip CIDR for proxy subnet"
  default     = "10.129.0.0/23"
}

variable "proxy_subnet_purpose" {
  type        = string
  description = "Purpose for proxy subnet"
  default     = "REGIONAL_MANAGED_PROXY"
}

variable "proxy_subnet_role" {
  type        = string
  description = "Role for proxy subnet"
  default     = "ACTIVE"
}

variable "lb_address_name" {
  type        = string
  description = "Name for LB address"
  default     = "lb-address"
}

variable "lb_address_type" {
  type        = string
  description = "Address type for LB address"
  default     = "EXTERNAL"
}

variable "lb_address_Network_tier" {
  type        = string
  description = "Network tier for LB address"
  default     = "STANDARD"
}

variable "backend_name" {
  type        = string
  description = "Name for webapp backend"
  default     = "webapp-backend"
}

variable "backend_load_balancing_scheme" {
  type        = string
  description = "Load Balancing Scheme for webapp backend"
  default     = "EXTERNAL_MANAGED"
}

variable "backend_protocol" {
  type        = string
  description = "Protocol for webapp backend"
  default     = "HTTP"
}

variable "backend_balancing_mode" {
  type        = string
  description = "Balancing Mode for webapp backend"
  default     = "UTILIZATION"
}

variable "backend_capacity_scaler" {
  type        = number
  description = "Capacity Scaler for webapp backend"
  default     = 1.0
}

variable "lb_url_name" {
  type        = string
  description = "Lb url name"
  default     = "lb-url-map"
}

variable "lb_target_proxy_name" {
  type        = string
  description = "Lb target proxy name"
  default     = "lb-target-proxy"
}

variable "lb_forwarding_rule_name" {
  type        = string
  description = "Lb forwarding rule name"
  default     = "lb-forwarding-rule"
}

variable "lb_forwarding_rule_protocol" {
  type        = string
  description = "Protocol for lb forwarding rule"
  default     = "TCP"
}

variable "lb_forwarding_rule_port_range" {
  type        = string
  description = "Port range for lb forwarding rule"
  default     = "443"
}

variable "lb_forwarding_rule_balancing_scheme" {
  type        = string
  description = "Balancing scheme for lb forwarding rule"
  default     = "EXTERNAL_MANAGED"
}

variable "lb_forwarding_rule_network_tier" {
  type        = string
  description = "Network tier for lb forwarding rule"
  default     = "STANDARD"
}

variable "ssl_cert_name" {
  type        = string
  description = "Name for ssl certificate"
  default     = "abhinav-certificate"
}

variable "ssl_cert_certificate" {
  type        = string
  description = "Certificate path for ssl certificate"
  default     = "D:\\Northeastern\\Courses\\cloud\\certificate\\choudhary-abhinav_me.crt"
}

variable "ssl_cert_private_key" {
  type        = string
  description = "Certificate path for ssl certificate"
  default     = "D:\\Northeastern\\Courses\\cloud\\certificate\\privateKey.pem"
}
