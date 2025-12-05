#########################################################
# sql.tf – Cloud SQL (PostgreSQL)
# makeAutomatic IaC – GCP
#########################################################

###############################################
# 1. Red privada para Cloud SQL
###############################################

resource "google_compute_global_address" "private_ip_range" {
  name          = "${var.resource_prefix}-sql-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.self_link
  service                 = "services/servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

###############################################
# 2. Instancia de Cloud SQL PostgreSQL
###############################################

resource "google_sql_database_instance" "main" {
  name             = var.sql_instance_name
  region           = var.region
  database_version = var.sql_database_version

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]

  settings {
    tier = var.sql_tier

    ip_configuration {
      ipv4_enabled    = false   # Seguridad: desactivar IP pública
      private_network = google_compute_network.main.self_link
    }

    backup_configuration {
      enabled = true
      point_in_time_recovery_enabled = true
    }

    maintenance_window {
      day  = 7   # Domingo
      hour = 3
    }

    database_flags {
      name  = "max_connections"
      value = "200"
    }

    database_flags {
      name  = "log_min_duration_statement"
      value = "500"
    }
  }
}

###############################################
# 3. Base de datos principal
###############################################

resource "google_sql_database" "main" {
  name     = "${var.resource_prefix}_db"
  instance = google_sql_database_instance.main.name
}

###############################################
# 4. Usuario de la base
###############################################

resource "google_sql_user" "main" {
  name     = var.sql_user
  instance = google_sql_database_instance.main.name
  password = var.sql_password
}
