#########################################################
# iam.tf – Service Accounts & Workload Identity Mapping
# makeAutomatic IaC – GCP
#########################################################

###############################################
# 1. Google Service Accounts (GSA)
###############################################

resource "google_service_account" "api" {
  account_id   = "${var.resource_prefix}-api-sa"
  display_name = "API Service Account (makeAutomatic)"
}

resource "google_service_account" "processor" {
  account_id   = "${var.resource_prefix}-processor-sa"
  display_name = "Processor Service Account (makeAutomatic)"
}

resource "google_service_account" "dashboard" {
  account_id   = "${var.resource_prefix}-dashboard-sa"
  display_name = "Dashboard Service Account (makeAutomatic)"
}

###############################################
# 2. IAM Roles mínimos para los servicios
###############################################

# --- API: Puede publicar al Topic ---
resource "google_project_iam_member" "api_pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.api.email}"
}

# --- Processor: Puede recibir mensajes ---
resource "google_project_iam_member" "processor_pubsub_subscriber" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.processor.email}"
}

# --- Processor: Puede conectarse a Cloud SQL ---
resource "google_project_iam_member" "processor_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.processor.email}"
}

# --- Dashboard: Puede conectarse a Cloud SQL ---
resource "google_project_iam_member" "dashboard_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.dashboard.email}"
}

# --- Todos: Pull de Artifact Registry ---
resource "google_project_iam_member" "artifactregistry_pull_api" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.api.email}"
}

resource "google_project_iam_member" "artifactregistry_pull_processor" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.processor.email}"
}

resource "google_project_iam_member" "artifactregistry_pull_dashboard" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.dashboard.email}"
}

###############################################
# 3. Workload Identity Bindings (GKE → GCP)
###############################################

# API
resource "google_service_account_iam_binding" "api_wi" {
  service_account_id = google_service_account.api.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[api/api-sa]"
  ]
}

# Processor
resource "google_service_account_iam_binding" "processor_wi" {
  service_account_id = google_service_account.processor.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[processor/processor-sa]"
  ]
}

# Dashboard
resource "google_service_account_iam_binding" "dashboard_wi" {
  service_account_id = google_service_account.dashboard.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[dashboard/dashboard-sa]"
  ]
}
