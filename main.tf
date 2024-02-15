module "vpc1" {
  source = "./config"
}

module "vpc2" {
  source      = "./config"
  network_name = "abhinav-vpc2"
  webapp_subnet_name = "webapp2"
  db_subnet_name = "db2"
  webapp_route_name = "webapp-route-2"
  ip_cidr_range_webapp = "10.1.1.0/24"
  ip_cidr_range_db = "10.1.2.0/24"
}