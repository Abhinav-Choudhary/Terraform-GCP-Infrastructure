variable "project" {
  type = string
  description = "GCP Project ID"
  default = "northeastern-cloud"
}

variable "region" {
  type = string
  description = "GCP Region"
  default = "us-east1"
}

variable "network_name" {
    type = string
    description = "Network Name"
    default = "abhinav-vpc"
}

variable "routing_mode" {
  type = string
  description = "Set routing mode to global or regional"
  default = "REGIONAL"
}

variable "auto_create_subnet" {
  type = bool
  description = "Specify whether default subnets should be autocreated"
  default = false
}

variable "delete_default_routes" {
  type = bool
  description = "Specify whether default routes should be created"
  default = false
}

variable "ip_cidr_range_webapp" {
    type = string
    description = "IP CIDR range for subnet webapp"
    default = "10.0.1.0/24"
}

variable "ip_cidr_range_db" {
    type = string
    description = "IP CIDR range for subnet db"
    default = "10.0.2.0/24"
}

variable "destination_range" {
  type = string
  description = "The destination range of outgoing packets that this route applies to. Only IPv4 is supported."
  default = "0.0.0.0/0"
}

variable "webapp_subnet_name" {
  type = string
  description = "Name for webapp subnet"
  default = "webapp"
}

variable "db_subnet_name" {
  type = string
  description = "Name for db subnet"
  default = "db"
}

variable "webapp_route_name" {
  type = string
  description = "Name for webapp route"
  default = "webapp-route"
}

variable "health_check_name" {
  type = string
  description = "Name for health check api"
  default = "proxy-health-check"
}

variable "health_check_interval" {
  type = number
  description = "Set how often (in seconds) to send a health check"
  default = 1
}

variable "health_check_timeout" {
  type = number
  description = "Set how long (in seconds) to wait before claiming failure."
  default = 1
}

variable "health_check_port" {
  type = string
  description = "The TCP port number for the TCP health check request."
  default = "80"
}

variable "backend_name" {
  type = string
  description = "Name for backend service"
  default = "compute-backend"
}

variable "forwarding_rule_name" {
  type = string
  description = "Name for forwarding rule"
  default = "compute-forwarding-rule"
}

variable "forwarding_load_balancing_scheme" {
  type = string
  description = "Specifies the forwarding rule type"
  default = "INTERNAL"
}

variable "forwarding_all_ports" {
  type = bool
  description = "Set the value of all ports field for forwarding rule"
  default = true
}