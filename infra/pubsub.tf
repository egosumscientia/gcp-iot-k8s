#########################################################
# pubsub.tf – Pub/Sub Topics & Subscriptions (IoT Ingest)
# makeAutomatic IaC – GCP
#########################################################

###############################################
# 1. Topic principal (IoT Events)
###############################################

resource "google_pubsub_topic" "main" {
  name = var.pubsub_topic_name
}

###############################################
# 2. Dead Letter Topic (DLQ)
###############################################

resource "google_pubsub_topic" "dlq" {
  name = "${var.pubsub_topic_name}-dlq"
}

###############################################
# 3. Subscription principal (Processor Worker)
###############################################

resource "google_pubsub_subscription" "main" {
  name  = var.pubsub_subscription_name
  topic = google_pubsub_topic.main.name

  ack_deadline_seconds = 20
  message_retention_duration = "1200s"  # 20 mins

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"  # 10 min
  }

  dead_letter_policy {
    dead_letter_topic = google_pubsub_topic.dlq.id
    max_delivery_attempts = 5
  }
}

###############################################
# 4. DLQ Subscription (para monitoreo)
###############################################

resource "google_pubsub_subscription" "dlq" {
  name  = "${var.pubsub_subscription_name}-dlq"
  topic = google_pubsub_topic.dlq.name

  ack_deadline_seconds = 20
  message_retention_duration = "3600s"  # 1 hora
}

###############################################
# 5. IAM – Permitir publicar a la API
###############################################

resource "google_pubsub_topic_iam_member" "api_publisher" {
  topic = google_pubsub_topic.main.name
  role  = "roles/pubsub.publisher"
  member = "serviceAccount:${var.resource_prefix}-api-sa@${var.project_id}.iam.gserviceaccount.com"
}

###############################################
# 6. IAM – Permitir consumir al Processor
###############################################

resource "google_pubsub_subscription_iam_member" "processor_subscriber" {
  subscription = google_pubsub_subscription.main.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${var.resource_prefix}-processor-sa@${var.project_id}.iam.gserviceaccount.com"
}
