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