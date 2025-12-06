###############################################
# Terraform Providers Configuration
# makeAutomatic – Infraestructura GCP
###############################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.0"
    }
  }
}

####################################################
# Providers
####################################################

provider "google" {
  credentials = file("C:/Users/petor/terraform.json")
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

provider "google-beta" {
  credentials = file("C:/Users/petor/terraform.json")
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}
