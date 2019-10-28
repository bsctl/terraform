# ------------------------------------------------------------------------------
# OUTPUTS
# ------------------------------------------------------------------------------

output "public_address" {
  value       = google_compute_global_address.default.address
  description = "The public IP address assigned to the Load Balancer"
}