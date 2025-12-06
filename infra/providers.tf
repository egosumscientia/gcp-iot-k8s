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


####################################################
# (Opcional, recomendado)
# Habilitar APIs necesarias del proyecto vía Terraform
####################################################
# Esta sección la activaremos en "main.tf":
#
#  - container.googleapis.com        (GKE)
#  - sqladmin.googleapis.com         (Cloud SQL)
#  - pubsub.googleapis.com           (Pub/Sub)
#  - artifactregistry.googleapis.com (Artifact Registry)
#
# module "enable_apis" {
#   source  = "terraform-google-modules/project-factory/google//modules/project_services"
#   version = "~> 14.0"
#
#   project_id = var.project_id
#   activate_apis = [
#     "container.googleapis.com",
#     "sqladmin.googleapis.com",
#     "pubsub.googleapis.com",
#     "art
