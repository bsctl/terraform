# ---------------------------------------------------------------------------------------------------------------------
# PARAMETERS
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

variable "custom_domain_name" {
  description = "Public custom domain name."
  type        = string
}

variable "dns_managed_zone_name" {
  description = "The name of the Cloud DNS Managed Zone in which to create the DNS A Records specified in 'var.custom_domain_names'. Only used if 'var.create_dns_entries' is true."
  type        = "string"
  default     = "replace-me"
}

variable "public_address" {
  description = "The public IP address used to resolve the DNS name."
  type        = list(string)
}

variable "dns_record_ttl" {
  description = "The time-to-live for the site A records (seconds)"
  type        = number
  default     = 300
}

# ------------------------------------------------------------------------------
# CREATE A RECORD POINTING TO THE PUBLIC IP OF THE CLB
# ------------------------------------------------------------------------------

resource "google_dns_record_set" "dns" {
  project      = var.project
  name         = "${var.custom_domain_name}."
  type         = "A"
  ttl          = var.dns_record_ttl
  managed_zone = var.dns_managed_zone_name
  rrdatas      = var.public_address
}

