#########################################################
# main.tf – makeautomatic IaC for GCP (Terraform Root Module)
#########################################################

###############################################
# Habilitación de APIs del proyecto GCP
###############################################

resource "google_project_service" "enabled_services" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "pubsub.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "servicenetworking.googleapis.com"
  ])

  service            = each.value
  disable_on_destroy = false
}

###############################################
# Labels comunes para todos los recursos
###############################################

locals {
  common_labels = {
    env     = var.env
    project = var.project_id
    owner   = "makeautomatic"
  }
}

###############################################
# Nota importante
###############################################
# Este archivo es el entrypoint del módulo raíz.
# TODOS los recursos estarán distribuidos en:
#
#  - vpc.tf
#  - gke.tf
#  - sql.tf
#  - pubsub.tf
#  - artifact_registry.tf
#  - iam.tf
#
# Terraform automáticamente carga todos los .tf del directorio.
###############################################
