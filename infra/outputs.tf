###############################################
# Terraform Outputs – makeAutomatic (GCP IaC)
###############################################

# -------------------------------------------------
# Información del proyecto y región
# -------------------------------------------------

output "project_id" {
  description = "ID del proyecto en GCP"
  value       = var.project_id
}

output "region" {
  description = "Región de despliegue"
  value       = var.region
}

# -------------------------------------------------
# VPC / NETWORK
# -------------------------------------------------

output "vpc_name" {
  description = "Nombre de la red VPC creada"
  value       = google_compute_network.main.name
}

output "subnet_name" {
  description = "Nombre de la subred utilizada"
  value       = google_compute_subnetwork.main.name
}

# -------------------------------------------------
# GKE CLUSTER
# -------------------------------------------------

output "gke_cluster_name" {
  description = "Nombre del cluster GKE"
  value       = google_container_cluster.primary.name
}

output "gke_endpoint" {
  description = "Endpoint del cluster GKE"
  value       = google_container_cluster.primary.endpoint
}

output "gke_ca_certificate" {
  description = "Certificado CA del cluster (para kubectl)"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

# -------------------------------------------------
# CLOUD SQL
# -------------------------------------------------

output "sql_instance_connection_name" {
  description = "Identificador para conectarse a la instancia Cloud SQL"
  value       = google_sql_database_instance.main.connection_name
}

output "sql_instance_ip" {
  description = "IP pública de la instancia SQL (solo si está habilitada)"
  value       = google_sql_database_instance.main.public_ip_address
}

output "sql_database_name" {
  description = "Nombre de la base de datos creada"
  value       = google_sql_database.main.name
}

# -------------------------------------------------
# PUB/SUB
# -------------------------------------------------

output "pubsub_topic" {
  description = "Nombre del Topic Pub/Sub utilizado"
  value       = google_pubsub_topic.main.name
}

output "pubsub_subscription" {
  description = "Nombre de la suscripción del Processor"
  value       = google_pubsub_subscription.main.name
}

# -------------------------------------------------
# ARTIFACT REGISTRY
# -------------------------------------------------

output "artifact_repo_url" {
  description = "URL del repositorio Docker en Artifact Registry"
  value       = google_artifact_registry_repository.main.repository_url
}

