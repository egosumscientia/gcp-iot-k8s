# Proyecto IoT + Microservicios + Kubernetes en GCP (Terraform IaC)

Plataforma demostrativa que procesa datos IoT con microservicios desplegados en Google Kubernetes Engine (GKE), Pub/Sub como bus de eventos y Cloud SQL como base de datos. El despliegue es manual (sin CI/CD) usando Terraform para la infraestructura.

## Objetivo
Implementar una arquitectura funcional que:
- Recibe datos IoT desde un cliente.
- Los envia a Pub/Sub.
- Los procesa mediante un microservicio worker.
- Los guarda en Cloud SQL.
- Los expone mediante un Dashboard en GKE.

## Arquitectura
Sensor -> API -> Pub/Sub -> Processor -> Cloud SQL -> Dashboard -> Usuario Final

## Componentes del Proyecto
### API Service
Microservicio en FastAPI que recibe eventos IoT via HTTP y los publica en Pub/Sub.

### Processor Service
Worker en Python que consume Pub/Sub y escribe en Cloud SQL.

### Dashboard Service
API simple que consulta Cloud SQL y expone lecturas recientes.

### Infraestructura en GCP
- GKE (Google Kubernetes Engine)
- Pub/Sub (topic y subscription)
- Cloud SQL (PostgreSQL)
- Artifact Registry para imagenes
- Cloud Logging y Monitoring

## Estructura de Carpetas
- microservices/api: codigo del servicio API
- microservices/processor: codigo del procesador
- microservices/dashboard: API de dashboard
- k8s/api: manifests de Kubernetes para API
- k8s/processor: manifests de Processor
- k8s/dashboard: manifests de Dashboard
- k8s/common: configmaps, secrets, serviceaccounts, namespaces
- docs: documentacion adicional

## Flujo General
1. El sensor envia datos JSON a la API.
2. La API publica los datos en Pub/Sub.
3. El Processor toma los mensajes y los escribe en Cloud SQL.
4. El Dashboard consulta la base y los muestra en tiempo real.
5. Kubernetes ejecuta, escala y mantiene los microservicios.

## Requisitos Previos
- Google Cloud SDK
- Docker
- kubectl
- Proyecto de GCP con APIs habilitadas:
  - Kubernetes Engine API
  - Cloud SQL Admin API
  - Pub/Sub API
  - Artifact Registry API

## Despliegue Resumido
1. Construir las imagenes Docker.
2. Subirlas a Artifact Registry.
3. Crear cluster GKE.
4. Crear instancia Cloud SQL.
5. Crear topic y subscription de Pub/Sub.
6. Crear secrets, configmaps y serviceaccounts.
7. Aplicar los manifests:
   ```
   kubectl apply -f k8s/
   ```
8. Enviar datos al endpoint `/ingest` de la API.

## Estado Final
- Tres microservicios corriendo en GKE.
- Pub/Sub como bus de eventos.
- Cloud SQL almacenando datos IoT.
- Dashboard mostrando informacion procesada.
- Logs gestionados por Cloud Logging.
