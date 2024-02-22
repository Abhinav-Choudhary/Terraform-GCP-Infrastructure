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
  type = number
  description = "Set priority for allow firewall rule"
  default = 900
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