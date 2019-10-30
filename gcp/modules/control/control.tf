// VARIABLES
variable "name" {
  type = "string"
}

variable "env" {
  type = string
}

variable "zone" {
  type = "string"
}

variable "template" {
  type = "string"
}

// MAIN CODE

resource "google_compute_instance_from_template" "masters" {
  name                     = "${var.name}-master-${count.index}"
  zone                     = var.zone
  source_instance_template = var.template
  lifecycle {
    create_before_destroy = true
  }
  count = 3
}

resource "google_compute_instance_group" "masters" {
  name = "${var.name}-control-instance-group"
  zone = var.zone
  instances = [
    google_compute_instance_from_template.masters[0].self_link,
    google_compute_instance_from_template.masters[1].self_link,
    google_compute_instance_from_template.masters[2].self_link
  ]
}

// OUTPUTS
output "masters-instance-group" {
  value       = google_compute_instance_group.masters.self_link
  description = "The name of the created instance group"
}