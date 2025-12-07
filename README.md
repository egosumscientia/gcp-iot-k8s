# Proyecto IoT + Microservicios + Kubernetes en GCP (Terraform IaC)

Plataforma demostrativa que procesa datos IoT con microservicios desplegados en Google Kubernetes Engine (GKE), Pub/Sub como bus de eventos y Cloud SQL como base de datos. El despliegue es manual (sin CI/CD) usando Terraform para la infraestructura.

## Objetivo
Implementar una arquitectura funcional que:
- Recibe datos IoT desde un cliente.
- Los envía a Pub/Sub.
- Los procesa mediante un microservicio Worker.
- Los guarda en Cloud SQL.
- Opcionalmente los expone mediante un Dashboard en GKE.

## Arquitectura
Sensor → API → Pub/Sub → Processor → Cloud SQL → Dashboard → Usuario Final

## Componentes del Proyecto

### API Service
Microservicio en FastAPI que recibe eventos IoT vía HTTP y los publica en Pub/Sub.

### Processor Service
Worker en Python que consume mensajes Pub/Sub y los escribe en Cloud SQL mediante Cloud SQL Python Connector utilizando el driver `pg8000`.

### Dashboard Service
Servicio HTTP que consulta Cloud SQL y expone un endpoint JSON para visualizar lecturas recientes.

### Infraestructura en GCP
- GKE (Google Kubernetes Engine)
- Pub/Sub (Topic + Subscription)
- Cloud SQL (PostgreSQL)
- Artifact Registry para imágenes Docker
- Cloud Logging y Cloud Monitoring

## Estructura del Proyecto
- microservices/api → código del microservicio API
- microservices/processor → código del Worker/Processor
- microservices/dashboard → código del Dashboard
- k8s/api → manifests Kubernetes de API
- k8s/processor → manifests de Processor
- k8s/dashboard → manifests del Dashboard
- k8s/common → configmaps, secrets, namespaces, serviceaccounts y Job de inicialización de base de datos
- infra → Terraform para red, Pub/Sub, GKE, Cloud SQL y Artifact Registry
- docs → documentación

## Inicialización Automática de la Base de Datos

El proyecto incluye un Job de Kubernetes (`db-init-job`), ubicado en `k8s/common`, que:

- Se ejecuta automáticamente al aplicar `kubectl apply -f k8s/common`.
- Conecta a Cloud SQL mediante Cloud SQL Python Connector.
- Crea la tabla `iot_readings` si no existe.
- Crea el índice optimizado para consultas por `device_id` y `timestamp`.
- Valida cuántos registros existen.

El Job ejecuta el siguiente SQL:

```sql
CREATE TABLE IF NOT EXISTS iot_readings (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(100) NOT NULL,
    temperature FLOAT NOT NULL,
    humidity FLOAT NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_device_timestamp 
ON iot_readings(device_id, timestamp);
