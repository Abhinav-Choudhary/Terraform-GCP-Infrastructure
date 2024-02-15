module "vpc1" {
  source = "./config"
}

module "vpc2" {
  source      = "./config"
  network_name = "abhinav-vpc6"
  webapp_subnet_name = "webapp6"
  db_subnet_name = "db6"
  webapp_route_name = "webapp-route-6"
  ip_cidr_range_webapp = "10.1.1.0/24"
  ip_cidr_range_db = "10.1.2.0/24"
}