// VARIABLES
variable "name" {
  type = "string"
}

variable "env" {
  type = string
}

variable "region" {
  type = "string"
}

variable "zone" {
  type = "string"
}

variable "node-cidr" {
  type    = "string"
  default = "10.10.10.0/24"
}

variable "svc-cidr" {
  type    = "string"
  default = "10.32.0.0/16"
}

variable "pod-cidr" {
  type    = "string"
  default = "10.244.0.0/16"
}

variable "access_ports" {
  type    = "list"
  default = ["22", "80", "443"]
}

// MAIN CODE

resource "google_compute_network" "main" {
  name                    = "${var.name}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name                     = "${var.name}-subnet"
  ip_cidr_range            = var.node-cidr
  network                  = google_compute_network.main.self_link
  region                   = var.region
  private_ip_google_access = true

  secondary_ip_range = [{
    range_name    = "svc-cidr"
    ip_cidr_range = var.svc-cidr
    },
    {
      range_name    = "pod-cidr"
      ip_cidr_range = var.pod-cidr
    },
  ]
}

resource "google_compute_firewall" "pods" {
  name      = "${var.name}-pods-internal"
  network   = google_compute_network.main.self_link
  direction = "INGRESS"

  allow {
    protocol = "tcp"
  }

  target_tags   = [var.name]
  source_ranges = [var.pod-cidr]
}

resource "google_compute_firewall" "internal" {
  name      = "${var.name}-internal"
  network   = google_compute_network.main.self_link
  direction = "INGRESS"

  allow {
    protocol = "all"
  }

  target_tags = [var.name]
  source_tags = [var.name]
}


resource "google_compute_firewall" "external" {
  name      = "${var.name}-external"
  network   = google_compute_network.main.self_link
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = var.access_ports
  }

  target_tags   = [var.name]
  source_ranges = ["0.0.0.0/0"]
}

// OUTPUTS
output "network" {
  value = google_compute_network.main.self_link
}

output "subnetwork" {
  value = google_compute_subnetwork.main.self_link
}