// VARIABLES

variable "name" {
  type = "string"
}

variable "network" {
  type = "string"
}

variable "subnet" {
  type = "string"
}

variable "machine_type" {
  type    = "string"
  default = "f1-micro"
}

variable "image" {
  type    = "string"
  default = "centos-cloud/centos-7"
}


// MAIN CODE
resource "google_compute_instance_template" "main" {
  name        = "${var.name}-node-template"
  description = "This template is used to create instances."

  tags = [var.name]

  labels = {
    environment = var.name
  }

  instance_description = "description assigned to instances"
  machine_type         = var.machine_type
  can_ip_forward       = true

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  lifecycle {
    create_before_destroy = true
  }

  disk {
    #source_image = "centos-cloud/centos-7"
    #source_image = "devops-256916/kube"
    source_image = var.image
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet
    access_config {
    }
  }
}


// OUTPUTS
output "instance_template" {
  value       = google_compute_instance_template.main.self_link
  description = "The created template"
}

