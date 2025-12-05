#########################################################
# artifact_registry.tf – Docker Repository (GCP)
# makeAutomatic IaC – GCP
#########################################################

###############################################
# 1. Repositorio principal en Artifact Registry
###############################################

resource "google_artifact_registry_repository" "main" {
  repository_id = var.artifact_repo_name
  location      = var.artifact_repo_location
  format        = "DOCKER"

  description = "Repositorio Docker para microservicios IoT/microservicios makeAutomatic"
}

###############################################
# 2. IAM – Permitir pulls desde GKE (nodos)
###############################################

resource "google_artifact_registry_repository_iam_member" "gke_pull" {
  repository = google_artifact_registry_repository.main.name
  location   = google_artifact_registry_repository.main.location

  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${var.project_id}.svc.id.goog"
}

###############################################
# 3. IAM – Permitir pulls al API Service Account
###############################################

resource "google_artifact_registry_repository_iam_member" "api_pull" {
  repository = google_artifact_registry_repository.main.name
  location   = google_artifact_registry_repository.main.location

  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${var.resource_prefix}-api-sa@${var.project_id}.iam.gserviceaccount.com"
}

###############################################
# 4. IAM – Permitir pulls al Processor Service Account
###############################################

resource "google_artifact_registry_repository_iam_member" "processor_pull" {
  repository = google_artifact_registry_repository.main.name
  location   = google_artifact_registry_repository.main.location

  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${var.resource_prefix}-processor-sa@${var.project_id}.iam.gserviceaccount.com"
}
