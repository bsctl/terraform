# ------------------------------------------------------------------------------
# CREATE A PUBLIC IP ADDRESS AS LOAD BALANCER FRONTEND
# ------------------------------------------------------------------------------

resource "google_compute_global_address" "default" {
  project      = var.project
  name         = "${var.name}-global-address"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

# ------------------------------------------------------------------------------
# IF PLAIN HTTP ENABLED, CREATE FORWARDING RULE AND PROXY
# ------------------------------------------------------------------------------

resource "google_compute_target_http_proxy" "http" {
  count   = var.enable_http ? 1 : 0
  project = var.project
  name    = "${var.name}-http-proxy"
  url_map = google_compute_url_map.urlmap.self_link
}

resource "google_compute_global_forwarding_rule" "http" {
  provider   = google-beta
  count      = var.enable_http ? 1 : 0
  project    = var.project
  name       = "${var.name}-http-rule"
  target     = google_compute_target_http_proxy.http[0].self_link
  ip_address = google_compute_global_address.default.address
  port_range = "80"
  depends_on = [google_compute_global_address.default]
}

# ------------------------------------------------------------------------------
# IF SSL ENABLED, CREATE FORWARDING RULE AND PROXY
# ------------------------------------------------------------------------------

resource "google_compute_global_forwarding_rule" "https" {
  provider   = google-beta
  project    = var.project
  count      = var.enable_ssl ? 1 : 0
  name       = "${var.name}-https-rule"
  target     = google_compute_target_https_proxy.default[0].self_link
  ip_address = google_compute_global_address.default.address
  port_range = "443"
  depends_on = [google_compute_global_address.default]
}

resource "google_compute_target_https_proxy" "default" {
  project          = var.project
  count            = var.enable_ssl ? 1 : 0
  name             = "${var.name}-https-proxy"
  url_map          = google_compute_url_map.urlmap.self_link
  ssl_certificates = var.ssl_certificates
}

# ------------------------------------------------------------------------------
# CREATE THE URL MAP TO MAP PATHS TO BACKENDS
# ------------------------------------------------------------------------------

resource "google_compute_url_map" "urlmap" {
  project = var.project

  name        = "${var.name}-global-loadbalacer"
  description = "URL map for ${var.name}"

  default_service = google_compute_backend_service.workers.self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "all"
  }

  path_matcher {
    name            = "all"
    default_service = google_compute_backend_service.workers.self_link
  }
}

# ------------------------------------------------------------------------------
# CREATE THE BACKEND SERVICE CONFIGURATION FOR THE INSTANCE GROUP
# ------------------------------------------------------------------------------

resource "google_compute_backend_service" "workers" {
  project = var.project

  name        = "${var.name}-workers-backend"
  description = "Backend for ${var.name} workers"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10
  enable_cdn  = false

  backend {
    description = "instance groups used as backend"
    group       = var.backends
  }

  health_checks = ["${element(compact(concat(google_compute_health_check.tcp.*.self_link, google_compute_health_check.http.*.self_link, google_compute_health_check.https.*.self_link)), 0)}"]

  depends_on = [var.backends]
}

# ------------------------------------------------------------------------------
# CONFIGURE HEALTH CHECK FOR THE BACKEND
# ------------------------------------------------------------------------------

resource "google_compute_health_check" "tcp" {
  count   = "${var.http_health_check || var.https_health_check ? 0 : 1}"
  project = "${var.project}"
  name    = "${var.name}-external-health-check"

  tcp_health_check {
    port = "${var.health_port}"
  }
}

resource "google_compute_health_check" "http" {
  count   = "${var.http_health_check ? 1 : 0}"
  project = "${var.project}"
  name    = "${var.name}-external-health-check"

  http_health_check {
    port         = "${var.health_port}"
    request_path = "${var.health_path}"
  }
}

resource "google_compute_health_check" "https" {
  count   = "${var.https_health_check ? 1 : 0}"
  project = "${var.project}"
  name    = "${var.name}-external-health-check"

  https_health_check {
    port         = "${var.health_port}"
    request_path = "${var.health_path}"
  }
}
