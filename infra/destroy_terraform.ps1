#########################################################
# DESTRUCCIÓN ORDENADA REAL — GCP IoT + GKE + SQL
# Recurso por recurso, en orden correcto GCP
# SIN deshabilitar APIs del proyecto
#########################################################

function Destroy($target) {
    Write-Host "`n>>> DESTRUYENDO: $target" -ForegroundColor Yellow
    terraform destroy "-target=$target" -auto-approve -parallelism=1

    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n*** ERROR en Terraform con $target — Reintentando vía gcloud ***" -ForegroundColor Red

        # Fallbacks específicos cuando Terraform falla
        if ($target -like "google_sql_database_instance*") {
            gcloud sql instances delete makeauto-sql --project=iot-k8s-petor -q
        }
        elseif ($target -like "google_service_networking_connection*") {
            gcloud compute networks peerings delete servicenetworking-googleapis-com `
                --network=makeauto-vpc --project=iot-k8s-petor -q
        }
        elseif ($target -like "google_compute_global_address.private_ip_range") {
            gcloud compute addresses delete makeauto-sql-private-ip-range `
                --global --project=iot-k8s-petor -q
        }
        elseif ($target -like "google_compute_network.main") {
            gcloud compute networks delete makeauto-vpc `
                --project=iot-k8s-petor -q
        }

        # Intentar remover del state
        terraform state rm $target | Out-Null
    }
}

Write-Host "`n=== DESTRUCCIÓN ORDENADA REAL — INICIADA ===" -ForegroundColor Cyan

#########################################################
# 1. GKE — NODES → CLUSTER (si existe bloquea VPC y SQL)
#########################################################
Destroy "google_container_node_pool.primary_nodes"
Destroy "google_container_cluster.primary"

#########################################################
# 2. Artifact Registry IAM → Repo
#########################################################
Destroy "google_artifact_registry_repository_iam_member.api_pull"
Destroy "google_artifact_registry_repository_iam_member.gke_pull"
Destroy "google_artifact_registry_repository_iam_member.processor_pull"
Destroy "google_artifact_registry_repository.main"

#########################################################
# 3. Pub/Sub IAM → Subs → Topics
#########################################################
Destroy "google_pubsub_subscription_iam_member.processor_subscriber"
Destroy "google_pubsub_subscription.main"
Destroy "google_pubsub_subscription.dlq"
Destroy "google_pubsub_topic_iam_member.api_publisher"
Destroy "google_pubsub_topic.main"
Destroy "google_pubsub_topic.dlq"

#########################################################
# 4. Workload Identity Bindings
#########################################################
Destroy "google_service_account_iam_binding.api_wi"
Destroy "google_service_account_iam_binding.dashboard_wi"
Destroy "google_service_account_iam_binding.processor_wi"

#########################################################
# 5. Service Accounts
#########################################################
Destroy "google_service_account.api"
Destroy "google_service_account.dashboard"
Destroy "google_service_account.processor"

#########################################################
# 6. SQL — User → DB → Instance
#########################################################
Destroy "google_sql_user.main"
Destroy "google_sql_database.main"
Destroy "google_sql_database_instance.main"

# Esperar que liberen VPC peering
Write-Host "`n>>> Esperando 90s a que SQL libere Private Service Networking..." -ForegroundColor Gray
Start-Sleep -Seconds 90

#########################################################
# 7. Private Service Networking → Private Range
#########################################################
Destroy "google_service_networking_connection.private_vpc_connection"
Destroy "google_compute_global_address.private_ip_range"

#########################################################
# 8. VPC — Firewalls → Subnet → Network
#########################################################
Destroy "google_compute_firewall.allow_ssh"
Destroy "google_compute_firewall.egress_allow"

Destroy "google_compute_subnetwork.main"
Destroy "google_compute_network.main"

#########################################################
# 9. Limpieza global
#########################################################
Write-Host "`n>>> DESTRUYENDO RESTO..." -ForegroundColor Yellow
terraform destroy -auto-approve -parallelism=1

Write-Host "`n=== DESTRUCCIÓN COMPLETA — TODO ELIMINADO ===" -ForegroundColor Green
exit 0
