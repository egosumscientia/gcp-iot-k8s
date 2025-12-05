#########################################################
# vpc.tf – Networking (VPC, Subnets, IP ranges)
# makeAutomatic IaC – GCP
#########################################################

###############################################
# VPC principal
###############################################

resource "google_compute_network" "main" {
  name                    = var.network_name
  auto_create_subnetworks = false

  routing_mode = "REGIONAL"
}

###############################################
# Subred principal para workloads (GKE)
###############################################

resource "google_compute_subnetwork" "main" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip_range
  region        = var.region
  network       = google_compute_network.main.id

  private_ip_google_access = true

  # Rango para Pods
  secondary_ip_range {
    range_name    = "${var.resource_prefix}-pods"
    ip_cidr_range = "10.20.0.0/16"
  }

  # Rango para Services
  secondary_ip_range {
    range_name    = "${var.resource_prefix}-services"
    ip_cidr_range = "10.30.0.0/20"
  }
}

###############################################
# Firewall rules mínimas
###############################################

resource "google_compute_firewall" "egress_allow" {
  name    = "${var.resource_prefix}-egress-allow"
  network = google_compute_network.main.name

  direction = "EGRESS"
  priority  = 1000

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
}

# SSH opcional (deshabilitado por defecto)
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.resource_prefix}-allow-ssh"
  network = google_compute_network.main.name

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]

  disabled = true
}
