#########################################################
# DESTRUCCIÓN ORDENADA REAL — GCP IoT + GKE + SQL
#########################################################

function Destroy($target) {
    Write-Host "`n>>> Destruyendo: $target" -ForegroundColor Yellow
    terraform destroy "-target=$target" -auto-approve -parallelism=1
}

Write-Host "`n=== DESTRUCCIÓN ORDENADA INICIADA ===" -ForegroundColor Cyan

# 1. PUBSUB IAM → SUBSCRIPTIONS → TOPICS
Destroy "google_pubsub_subscription_iam_member.processor_subscriber"
Destroy "google_pubsub_subscription.main"
Destroy "google_pubsub_subscription.dlq"
Destroy "google_pubsub_topic_iam_member.api_publisher"
Destroy "google_pubsub_topic.main"
Destroy "google_pubsub_topic.dlq"

# 2. SQL USER + DB → SQL INSTANCE
Destroy "google_sql_user.main"
Destroy "google_sql_database.main"
Destroy "google_sql_database_instance.main"

Start-Sleep -Seconds 40

# 3. SERVICE NETWORKING → PRIVATE IP RANGE
Destroy "google_service_networking_connection.private_vpc_connection"
Destroy "google_compute_global_address.private_ip_range"

# 4. GKE NODE POOL → CLUSTER
Destroy "google_container_node_pool.primary_nodes"
Destroy "google_container_cluster.primary"

# 5. ARTIFACT REGISTRY IAM → REPO
Destroy "google_artifact_registry_repository_iam_member.api_pull"
Destroy "google_artifact_registry_repository_iam_member.gke_pull"
Destroy "google_artifact_registry_repository_iam_member.processor_pull"
Destroy "google_artifact_registry_repository.main"

# 6. WORKLOAD IDENTITY BINDINGS → SERVICE ACCOUNTS
Destroy "google_service_account_iam_binding.api_wi"
Destroy "google_service_account_iam_binding.dashboard_wi"
Destroy "google_service_account_iam_binding.processor_wi"

Destroy "google_service_account.api"
Destroy "google_service_account.dashboard"
Destroy "google_service_account.processor"

# 7. FIREWALLS → SUBNET → VPC
Destroy "google_compute_firewall.allow_ssh"
Destroy "google_compute_firewall.egress_allow"

Destroy "google_compute_subnetwork.main"
Destroy "google_compute_network.main"

# 8. RESTO
Write-Host "`n>>> DESTRUYENDO RESTO (globally)..." -ForegroundColor Yellow
terraform destroy -auto-approve -parallelism=1

Write-Host "`n=== DESTRUCCIÓN COMPLETA ===" -ForegroundColor Green
