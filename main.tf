module "vpc1" {
  source = "./config"
}

module "vpc2" {
  source      = "./config"
  network_name = "abhinav-vpc2"
  webapp_subnet_name = "webapp2"
  db_subnet_name = "db2"
  webapp_route_name = "webapp-route-2"
  health_check_name = "proxy-health-check2"
  backend_name = "compute-backend2"
  forwarding_rule_name = "compute-forwarding-rule2"
}