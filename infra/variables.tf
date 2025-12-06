###############################################
# Terraform Variables – makeAutomatic (GCP IaC)
###############################################

# -------------------------------------------------
# Proyecto y ubicación
# -------------------------------------------------

variable "project_id" {
  description = "ID del proyecto en Google Cloud"
  type        = string
}

variable "region" {
  description = "Región principal donde se desplegarán los recursos"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zona por defecto para recursos zonales"
  type        = string
  default     = "us-central1-a"
}

# -------------------------------------------------
# VPC & Networking
# -------------------------------------------------

variable "network_name" {
  description = "Nombre de la VPC donde correrá el cluster"
  type        = string
  default     = "makeauto-vpc"
}

variable "subnet_name" {
  description = "Nombre de la subred del cluster"
  type        = string
  default     = "makeauto-subnet"
}

variable "subnet_ip_range" {
  description = "CIDR para la subred del cluster"
  type        = string
  default     = "10.10.0.0/24"
}

# -------------------------------------------------
# GKE Cluster
# -------------------------------------------------

variable "gke_cluster_name" {
  description = "Nombre del cluster de Kubernetes"
  type        = string
  default     = "makeauto-gke"
}

variable "gke_node_count" {
  description = "Cantidad inicial de nodos del node pool"
  type        = number
  default     = 1
}

variable "gke_machine_type" {
  description = "Tipo de máquina para los nodos del GKE"
  type        = string
  default     = "e2-medium"
}

# -------------------------------------------------
# Pub/Sub
# -------------------------------------------------

variable "pubsub_topic_name" {
  description = "Nombre del topic Pub/Sub donde la API publicará datos"
  type        = string
  default     = "iot-events"
}

variable "pubsub_subscription_name" {
  description = "Nombre de la suscripción para el microservicio Processor"
  type        = string
  default     = "iot-events-sub"
}

# -------------------------------------------------
# Cloud SQL
# -------------------------------------------------

variable "sql_instance_name" {
  description = "Nombre de la instancia de Cloud SQL (PostgreSQL)"
  type        = string
  default     = "makeauto-sql"
}

variable "sql_database_version" {
  description = "Versión de PostgreSQL"
  type        = string
  default     = "POSTGRES_15"
}

variable "sql_tier" {
  description = "Máquina de Cloud SQL"
  type        = string
  default     = "db-f1-micro"
}

variable "sql_user" {
  description = "Usuario administrador de la base"
  type        = string
  default     = "iotservice"
}

variable "sql_password" {
  description = "Password para el usuario de SQL (se recomienda Secret Manager)"
  type        = string
  sensitive   = true
}

# -------------------------------------------------
# Artifact Registry
# -------------------------------------------------

variable "artifact_repo_name" {
  description = "Nombre del repositorio para almacenar imágenes Docker"
  type        = string
  default     = "makeauto-repo"
}

variable "artifact_repo_location" {
  description = "Ubicación del repositorio"
  type        = string
  default     = "us-central1"
}

# -------------------------------------------------
# Tags y organización general
# -------------------------------------------------

variable "env" {
  description = "Ambiente de despliegue (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "resource_prefix" {
  description = "Prefijo que usarán todos los recursos creados"
  type        = string
  default     = "makeauto"
}
