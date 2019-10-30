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

variable "num" {
  default = 1
}

variable "template" {
  type = "string"
}

// MAIN CODE
resource "google_compute_instance_group_manager" "compute" {
  name               = "${var.name}-compute-instance-group"
  base_instance_name = "${var.name}-compute"
  instance_template  = var.template
  zone               = var.zone
  target_size        = var.num
  lifecycle {
    create_before_destroy = true
  }
}

// OUTPUTS
output "instance-group" {
  value       = google_compute_instance_group_manager.compute.instance_group
  description = "The name of the created instance group"
}