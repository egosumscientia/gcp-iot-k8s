# Proyecto IoT + Microservicios + Kubernetes en Google Cloud Platform (GCP) utilizando Terraform (IaC)

Plataforma demostrativa que procesa datos IoT usando microservicios desplegados en Google Kubernetes Engine (GKE), Pub/Sub como sistema de mensajería y Cloud SQL como base de datos. El despliegue es manual (sin CI/CD). Se usa Terraform para la IaC.

## Objetivo
Implementar una arquitectura funcional que:
- Recibe datos IoT desde un cliente.
- Los envía a Pub/Sub.
- Los procesa mediante un microservicio trabajador.
- Los guarda en Cloud SQL.
- Los expone mediante un Dashboard alojado en GKE.

## Arquitectura
Sensor → API → Pub/Sub → Processor → Cloud SQL → Dashboard → Usuario Final

## Componentes del Proyecto
### API Service
Microservicio en FastAPI que recibe eventos IoT vía HTTP.

### Processor Service
Microservicio en Python que recibe mensajes de Pub/Sub y escribe en Cloud SQL.

### Dashboard Service
Aplicación simple que consulta Cloud SQL y muestra los datos recientes.

### Infraestructura en GCP
- GKE (Google Kubernetes Engine)
- Pub/Sub (topic y subscription)
- Cloud SQL (PostgreSQL)
- Artifact Registry para las imágenes
- Cloud Logging y Monitoring

## Estructura de Carpetas
- microservices/api → código del servicio API
- microservices/processor → código del procesador
- microservices/dashboard → dashboard web
- k8s/api → manifests de Kubernetes para API
- k8s/processor → manifests de Processor
- k8s/dashboard → manifests de Dashboard
- k8s/common → configmaps, secrets, etc.
- docs → documentación adicional

## Flujo General
1. El sensor envía datos JSON a la API.
2. La API publica los datos en Pub/Sub.
3. El Processor toma los mensajes y los escribe en Cloud SQL.
4. El Dashboard consulta la base y los muestra en tiempo real.
5. Kubernetes ejecuta, escala y mantiene los microservicios.

## Requisitos Previos
- Google Cloud SDK
- Docker
- kubectl
- Proyecto de GCP con las APIs habilitadas:
  - Kubernetes Engine API
  - Cloud SQL Admin API
  - Pub/Sub API

## Despliegue Resumido
1. Construir las imágenes Docker.
2. Subirlas a Artifact Registry.
3. Crear cluster GKE.
4. Crear instancia Cloud SQL.
5. Crear topic y subscription de Pub/Sub.
6. Crear secrets y configmaps.
7. Aplicar los manifests:
   ```
   kubectl apply -f k8s/
   ```
8. Enviar datos al endpoint `/ingest` de la API.

## Estado Final
- Tres microservicios corriendo en GKE.
- Pub/Sub funcionando como bus de eventos.
- Cloud SQL almacenando datos IoT.
- Dashboard mostrando información procesada.
- Logs gestionados por Cloud Logging.

## Uso
Enviar datos de prueba en formato JSON a la API y verificar el procesamiento completo desde GKE hasta Cloud SQL y Dashboard.

