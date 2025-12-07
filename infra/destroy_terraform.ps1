#########################################################
# Script de Destrucción Ordenada de Terraform
# Proyecto: IoT + K8s + GCP
#########################################################

Write-Host "`n=== Iniciando destrucción ordenada de recursos ===" -ForegroundColor Cyan

# Paso 1: Destruir recursos de aplicación
Write-Host "`n[1/5] Destruyendo recursos de aplicación..." -ForegroundColor Yellow
terraform destroy -auto-approve `
  -target=google_sql_database.main `
  -target=google_sql_user.main

# Paso 2: Destruir instancia Cloud SQL
Write-Host "`n[2/5] Destruyendo instancia Cloud SQL..." -ForegroundColor Yellow
terraform destroy -auto-approve `
  -target=google_sql_database_instance.main

# Esperar a que SQL termine de eliminarse
Write-Host "`nEsperando 30 segundos para que Cloud SQL termine de eliminarse..." -ForegroundColor Gray
Start-Sleep -Seconds 30

# Paso 3: Destruir conexión de Service Networking
Write-Host "`n[3/5] Destruyendo conexión de Service Networking..." -ForegroundColor Yellow
terraform destroy -auto-approve `
  -target=google_service_networking_connection.private_vpc_connection

# Paso 4: Destruir rango de IPs privadas
Write-Host "`n[4/5] Destruyendo rango de IPs privadas..." -ForegroundColor Yellow
terraform destroy -auto-approve `
  -target=google_compute_global_address.private_ip_range

# Paso 5: Destruir todo lo demás
Write-Host "`n[5/5] Destruyendo todos los recursos restantes..." -ForegroundColor Yellow
terraform destroy -auto-approve

# Verificar que todo se eliminó
Write-Host "`n=== Verificando estado final ===" -ForegroundColor Cyan
$remaining = terraform state list
if ($remaining) {
    Write-Host "`n⚠️  Todavía quedan recursos:" -ForegroundColor Red
    terraform state list
    Write-Host "`nEjecuta manualmente: terraform destroy" -ForegroundColor Yellow
} else {
    Write-Host "`n✅ Todos los recursos fueron destruidos exitosamente!" -ForegroundColor Green
}

Write-Host "`n=== Proceso completado ===" -ForegroundColor Cyan