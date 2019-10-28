# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The project ID to create the resources in."
  type        = string
}

variable "name" {
  description = "Name for the load balancer forwarding rule and prefix for supporting resources."
  type        = string
}

variable "enable_ssl" {
  description = "Set to true to enable ssl. If set to 'true', you will also have to provide 'var.ssl_certificates'."
  type        = bool
  default     = false
}

variable "ssl_certificates" {
  description = "List of SSL cert self links. Required if 'enable_ssl' is 'true'."
  type        = list(string)
  default     = []
}

variable "enable_http" {
  description = "Set to true to enable plain http. Note that disabling http does not force SSL and/or redirect HTTP traffic. See https://issuetracker.google.com/issues/35904733"
  type        = bool
  default     = true
}

variable "create_dns_entries" {
  description = "If set to true, create a DNS A Record in Cloud DNS for each domain specified in 'custom_domain_names'."
  type        = bool
  default     = false
}

variable "domain_names" {
  description = "List of custom domain names."
  type        = list(string)
  default     = []
}

variable "dns_managed_zone_name" {
  description = "The name of the Cloud DNS Managed Zone in which to create the DNS A Records specified in 'var.custom_domain_names'. Only used if 'var.create_dns_entries' is true."
  type        = "string"
  default     = "replace-me"
}


variable backends {
  description = ""
  type        = "string"
}

variable session_affinity {
  type        = "string"
  description = "The session affinity for the backends example: NONE, CLIENT_IP. Default is `NONE`."
  default     = "NONE"
}

variable ports {
  description = "List of ports to forward to backend services."
  type        = "list"
  default     = []
}

variable tcp_health_check {
  description = "Set to true if health check is type tcp."
  default     = false
}

variable http_health_check {
  description = "Set to true if health check is type http."
  default     = true
}

variable https_health_check {
  description = "Set to true if health check is type https"
  default     = false
}

variable health_port {
  type        = "string"
  description = "Port to perform health checks on."
}

variable health_path {
  type        = "string"
  description = "Path to perform health checks on."
}