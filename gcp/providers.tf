// PROVIDER
provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

provider "google-beta" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
  zone        = var.zone
}