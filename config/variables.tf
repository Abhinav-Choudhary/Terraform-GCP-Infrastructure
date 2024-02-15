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
  default = true
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

variable "internet_gateway" {
  type = string
  description = "Set the default internet gateway"
  default = "default-internet-gateway"
}