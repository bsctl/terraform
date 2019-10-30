variable "name" {
  type    = "string"
  default = "noverit"
}

variable "project" {
  type = "string"
}

variable "credentials" {
  type = "string"
}

variable "env" {
  type    = string
  default = "dev"
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

variable "masters_health_port" {
  type        = "string"
  default     = "6443"
  description = "Port used for master health check"
}

variable "masters_health_path" {
  type        = "string"
  default     = "/healthz"
  description = "Path used for master health check"
}

variable "workers_health_port" {
  type        = "string"
  default     = "80"
  description = "Port used for workers health check. Require Reverse Proxy listening."
}

variable "workers_health_path" {
  type        = "string"
  default     = "/"
  description = "Path used for workers health check. Require Reverse Proxy listening."
}

variable session_affinity {
  type        = "string"
  description = "The session affinity for the backends example: NONE, CLIENT_IP. Default is `NONE`."
  default     = "CLIENT_IP"
}

variable "cluster_size" {
  type        = "string"
  default     = "3"
  description = "Number of worker nodes"
}

variable "domain_name" {
  type        = "string"
  default     = "k8s.noverit.com"
  description = "DNS name for global loadbalancer"
}

variable "managed_zone_name" {
  type        = "string"
  default     = "noverit"
  description = "managed DNS zone used for global loadbalancer"
}



