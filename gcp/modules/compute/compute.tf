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

variable "node_type" {
  type = "string"
}

variable "image" {
  type    = "string"
  default = "centos-cloud/centos-7"
}

variable "public_address" {
  description = "The public IP addresses list"
  type        = list(string)
}

// MAIN CODE
resource "google_compute_instance" "node" {
  allow_stopping_for_update = true
  name        = "${var.name}-${var.node_type}-${count.index}"
  description = ""
  zone        = var.zone

  tags = [var.name]

  labels = {
    environment = var.name
  }

  machine_type   = var.machine_type
  can_ip_forward = true

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  lifecycle {
    create_before_destroy = true
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      image = var.image
    }
  }

  metadata_startup_script = "sudo yum update -y"

  network_interface {
    network    = var.network
    subnetwork = var.subnet
    access_config {
      nat_ip = var.public_address[count.index]
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  count = var.num
}

resource "google_compute_instance_group" "node" {
  name      = "${var.name}-${var.node_type}-instance-group"
  zone      = var.zone
  instances = google_compute_instance.node[*].self_link
}

// OUTPUTS
output "instance-group" {
  value       = google_compute_instance_group.node.self_link
  description = "The name of the created instance group"
}