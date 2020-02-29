# For openshift
# terraform plan --var name=oscp --var env=prod --var image=openshift --var control_health_port=8443 --var num_workers=5

// VERSION
terraform {
  required_version = ">= 0.12"
}

// PROVIDER
provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

provider "google-beta" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

// NETWORK
module "network" {
  source       = "./modules/network"
  name         = var.name
  env          = var.env
  region       = var.region
  zone         = var.zone
  access_ports = ["22", "80", "443", "${var.control_health_port}"]
}

// LOAD BALANCER
module "lb-internal" {
  source             = "./modules/load-balancer"
  project            = var.project
  region             = var.region
  network            = module.network.network
  subnetwork         = module.network.subnetwork
  name               = var.name
  scheme             = "INTERNAL"
  source_tags        = ["${var.name}"]
  target_tags        = ["${var.name}"]
  backends           = module.node-masters.instance-group
  https_health_check = "true"
  http_health_check  = "false"
  health_port        = var.control_health_port
  health_path        = var.control_health_path
  session_affinity   = var.session_affinity
}

// ADDRESS
module "address-masters" {
  source = "./modules/address"
  name   = "${var.name}-master"
  num    = var.num_masters
  type   = "EXTERNAL"
}

module "address-workers" {
  source = "./modules/address"
  name   = "${var.name}-worker"
  num    = var.num_workers
  type   = "EXTERNAL"
}

module "address-bastion" {
  source = "./modules/address"
  name   = "${var.name}-bastion"
  num    = 1
  type   = "EXTERNAL"
}

// BASTION
module "bastion" {
  source         = "./modules/compute"
  name           = var.name
  env            = var.env
  zone           = var.zone
  num            = 1
  network        = module.network.network
  subnet         = module.network.subnetwork
  machine_type   = var.machine_types["test"]
  node_type      = "bastion"
  image          = "bastion"
  public_address = module.address-bastion.address 
}

// MASTER NODES
module "node-masters" {
  source         = "./modules/compute"
  name           = var.name
  env            = var.env
  zone           = var.zone
  num            = var.num_masters
  network        = module.network.network
  subnet         = module.network.subnetwork
  machine_type   = var.machine_types[var.env]
  node_type      = "master"
  image          = var.image
  public_address = module.address-masters.address 
}

// WORKER NODES
module "node-workers" {
  source         = "./modules/compute"
  name           = var.name
  env            = var.env
  zone           = var.zone
  num            = var.num_workers
  network        = module.network.network
  subnet         = module.network.subnetwork
  machine_type   = var.machine_types[var.env]
  node_type      = "worker"
  image          = var.image
  public_address = module.address-workers.address
}

// DNS
module "dns-bastion" {
  source                = "./modules/dns"
  name                  = "bastion"
  project               = var.project
  custom_domain_name    = "bastion.${var.name}.${var.domain_name}"
  dns_managed_zone_name = var.managed_zone_name
  public_address        = module.address-bastion.address
}

module "dns-control-plane" {
  source                = "./modules/dns"
  name                  = var.name
  project               = var.project
  custom_domain_name    = "master.${var.domain_name}"
  dns_managed_zone_name = var.managed_zone_name
  public_address        = module.address-masters.address
}

module "dns-applications" {
  source                = "./modules/dns"
  name                  = var.name
  project               = var.project
  custom_domain_name    = "*.${var.name}.${var.domain_name}"
  dns_managed_zone_name = var.managed_zone_name
  public_address        = module.address-workers.address
}

// VARIABLES
variable "name" {
  type    = "string"
  default = "kube"
}

variable "project" {
  type    = "string"
  default = "noverit-168407"
}

variable "credentials" {
  type = "string"
}

variable "env" {
  type    = string
  default = "test"
}

variable "region" {
  type    = "string"
  default = "europe-west1"
}

variable "zone" {
  type    = "string"
  default = "europe-west1-c"
}

variable "machine_types" {
  type = "map"
  default = {
    "dev"  = "f1-micro"
    "test" = "n1-standard-1"
    "prod" = "n1-standard-2"
  }
}

variable "image" {
  type    = "string"
  default = "kubernetes"
}

variable "control_health_port" {
  type        = "string"
  default     = "6443"
  description = "Port used for health check"
}

variable "control_health_path" {
  type        = "string"
  default     = "/healthz"
  description = "Path used for health check"
}

variable session_affinity {
  type        = "string"
  description = "The session affinity for the backends example: NONE, CLIENT_IP. Default is `NONE`."
  default     = "CLIENT_IP"
}

variable "num_workers" {
  type        = "string"
  default     = "3"
  description = "Number of worker nodes"
}

variable "num_masters" {
  type        = "string"
  default     = "3"
  description = "Number of master nodes"
}

variable "domain_name" {
  type        = "string"
  default     = "noverit.com"
  description = "DNS name for public access"
}

variable "managed_zone_name" {
  type        = "string"
  default     = "noverit"
  description = "managed DNS zone used for public access"
}