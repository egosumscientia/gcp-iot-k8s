#########################################################
# gke.tf – Google Kubernetes Engine
# makeautomatic IaC – GCP
#########################################################

###############################################
# Cluster GKE (VPC-Native)
###############################################

resource "google_container_cluster" "primary" {
  name     = var.gke_cluster_name
  location = var.region

  network    = google_compute_network.main.self_link
  subnetwork = google_compute_subnetwork.main.self_link

  # Rangos secundarios ya definidos en vpc.tf
  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.resource_prefix}-pods"
    services_secondary_range_name = "${var.resource_prefix}-services"
  }

  # Deshabilitamos el nodo por defecto que crea Google
  remove_default_node_pool = true

  initial_node_count = 1

  ###############################################
  # Seguridad del plano de control
  ###############################################

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  ###############################
  # Configuración del cluster
  ###############################

  networking_mode = "VPC_NATIVE"
  datapath_provider = "ADVANCED_DATAPATH"

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  resource_labels = {
    env     = var.env
    project = var.project_id
    owner   = "makeautomatic"
  }
}

###############################################
# Node Pool (Administrado)
###############################################

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.gke_cluster_name}-nodepool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_node_count

  node_config {
    machine_type = var.gke_machine_type

    # Permite pull de imágenes de Artifact Registry
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Activar Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      env   = var.env
      owner = "makeautomatic"
    }

    tags = [
      "${var.resource_prefix}-gke-nodes"
    ]
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
