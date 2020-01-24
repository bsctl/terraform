// VARIABLES
variable "name" {
  type = "string"
}

variable "num" {
  default = 1
}

variable "type" {
  type    = "string"
  default = "EXTERNAL"
}

// MAIN CODE
resource "google_compute_address" "nodes" {
  name         = "${var.name}-${count.index}"
  address_type = var.type
  count        = var.num
}

// OUTPUTS
output "address" {
  value       = google_compute_address.nodes[*].address
  description = "IP address list"
}