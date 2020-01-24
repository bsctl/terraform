// VARIABLES
variable project {
  type        = "string"
  description = "The project to deploy to, if not set the default provider project is used."
  default     = ""
}

variable region {
  type        = "string"
  description = "Region for cloud resources."
  default     = "europe-west1"
}

variable network {
  type        = "string"
  description = "Name of the network to create resources in."
  default     = "default"
}

variable subnetwork {
  type        = "string"
  description = "Name of the subnetwork to create resources in."
  default     = "default"
}

variable name {
  type        = "string"
  description = "Name for the forwarding rule and prefix for supporting resources."
}

variable backends {
  description = ""
  type        = "string"
}

variable service_label {
  description = ""
  type        = "string"
  default     = ""
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

variable http_health_check {
  description = "Set to true if health check is type http."
  default     = false
}

variable https_health_check {
  description = "Set to true if health check is type https"
  default     = true
}

variable tcp_health_check {
  description = "Set to true if health check is type tcp"
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

variable source_tags {
  description = "List of source tags for traffic between the internal load balancer."
  type        = "list"
}

variable target_tags {
  description = "List of target tags for traffic between the internal load balancer."
  type        = "list"
}

variable ip_protocol {
  type        = "string"
  description = "The IP protocol for the backend and frontend forwarding rule. TCP or UDP."
  default     = "TCP"
}

variable scheme {
  type        = "string"
  description = "The load balancer type. INTERNAL or EXTERNAL or INTERNAL_MANAGED"
  default     = "TCP"
}

// MAIN CODE

resource "google_compute_forwarding_rule" "default" {
  provider              = "google-beta"
  project               = "${var.project}"
  name                  = "${var.name}-internal-loadbalancer"
  region                = "${var.region}"
  network               = "${var.network}"
  subnetwork            = "${var.subnetwork}"
  load_balancing_scheme = "${var.scheme}"
  backend_service       = "${google_compute_region_backend_service.default.self_link}"
  service_label         = "${var.service_label == "" ? var.name : var.service_label}"
  ip_protocol           = "${var.ip_protocol}"
  all_ports             = true
}

resource "google_compute_region_backend_service" "default" {
  project          = "${var.project}"
  name             = "${var.name}-internal-loadbalancer"
  region           = "${var.region}"
  protocol         = "${var.ip_protocol}"
  timeout_sec      = 10
  session_affinity = "${var.session_affinity}"
  backend {
    description = "instance groups used as backend"
    group       = var.backends
  }
  health_checks = ["${element(compact(concat(google_compute_health_check.internal_tcp.*.self_link, google_compute_health_check.internal_http.*.self_link, google_compute_health_check.internal_https.*.self_link)), 0)}"]
}

resource "google_compute_health_check" "internal_tcp" {
  count   = "${var.http_health_check || var.https_health_check ? 0 : 1}"
  project = "${var.project}"
  name    = "${var.name}-internal-health-check"

  tcp_health_check {
    port = "${var.health_port}"
  }
}

resource "google_compute_health_check" "internal_http" {
  count   = "${var.http_health_check ? 1 : 0}"
  project = "${var.project}"
  name    = "${var.name}-internal-health-check"

  http_health_check {
    port         = "${var.health_port}"
    request_path = "${var.health_path}"
  }
}

resource "google_compute_health_check" "internal_https" {
  count   = "${var.https_health_check ? 1 : 0}"
  project = "${var.project}"
  name    = "${var.name}-internal-health-check"

  https_health_check {
    port         = "${var.health_port}"
    request_path = "${var.health_path}"
  }
}

resource "google_compute_firewall" "default-internal-loadbalancer" {
  project = "${var.project}"
  name    = "${var.name}-internal-loadbalancer"

  network = "${var.network}"

  allow {
    protocol = "${lower(var.ip_protocol)}"
    ports    = "${var.ports}"
  }

  source_tags = "${var.source_tags}"
  target_tags = "${var.target_tags}"
}

resource "google_compute_firewall" "default-health-check" {
  project = "${var.project}"
  name    = "${var.name}-internal-health-check"
  network = "${var.network}"

  allow {
    protocol = "${lower(var.ip_protocol)}"
    ports    = ["${var.health_port}"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = "${var.target_tags}"
}


// OUTPUTS
output ip_address {
  description = "The IP address assigned to the fowarding rule."
  value       = "${google_compute_forwarding_rule.default.ip_address}"
}