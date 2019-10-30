
// IMAGE TEMPLATE
module "template" {
  source       = "./modules/template"
  network      = module.network.network
  subnet       = module.network.subnetwork
  name         = var.name
  machine_type = var.machine_types[var.env]
  image        = var.image
}

// MASTER NODES
module "control" {
  source   = "./modules/control"
  name     = var.name
  env      = var.env
  zone     = var.zone
  template = module.template.instance_template
}

// NETWORK
module "network" {
  source = "./modules/network"
  name   = var.name
  env    = var.env
  region = var.region
  zone   = var.zone
}

// MASTERS LOAD BALANCER
module "lb-internal" {
  source             = "./modules/lb-internal"
  project            = var.project
  region             = var.region
  network            = module.network.network
  subnetwork         = module.network.subnetwork
  name               = var.name
  source_tags        = ["${var.name}"]
  target_tags        = ["${var.name}"]
  backends           = module.control.masters-instance-group
  https_health_check = "true"
  http_health_check  = "false"
  health_port        = var.masters_health_port
  health_path        = var.masters_health_path
  session_affinity   = var.session_affinity
}

// WORKER NODES
module "compute" {
  source   = "./modules/compute"
  name     = var.name
  env      = var.env
  zone     = var.zone
  template = module.template.instance_template
  num      = var.cluster_size
}

// DNS
module "dns" {
  source                = "./modules/dns"
  name                  = var.name
  project               = var.project
  custom_domain_name    = var.domain_name
  dns_managed_zone_name = var.managed_zone_name
  public_address        = [module.lb-global.public_address]
}

// WORKERS LOAD BALANCER
module "lb-global" {
  source             = "./modules/lb-global"
  name               = var.name
  project            = var.project
  enable_ssl         = true
  ssl_certificates   = [module.ssl.certificate]
  backends           = module.compute.instance-group
  https_health_check = "false"
  http_health_check  = "true"
  health_port        = var.workers_health_port
  health_path        = var.workers_health_path
  session_affinity   = var.session_affinity
}

// SSL
module "ssl" {
  source             = "./modules/ssl"
  name               = var.name
  project            = var.project
  custom_domain_name = var.domain_name
}
