import os
import json
import psycopg2
from fastapi import FastAPI, HTTPException
from google.cloud import pubsub_v1
from pydantic import BaseModel

# ------------------------------
# Environment Variables
# ------------------------------
PUBSUB_TOPIC = os.getenv("PUBSUB_TOPIC")
SQL_USER = os.getenv("SQL_USER")
SQL_PASSWORD = os.getenv("SQL_PASSWORD")
SQL_DB_NAME = os.getenv("SQL_DB_NAME", "makeauto_db")
SQL_INSTANCE = os.getenv("SQL_INSTANCE_CONNECTION_NAME")

# ------------------------------
# FastAPI App
# ------------------------------
app = FastAPI(title="makeAutomatic API Service")

# ------------------------------
# Pub/Sub Publisher (Workload Identity)
# ------------------------------
publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(
    os.getenv("PROJECT_ID", ""),  # optional; can be supplied in env
    PUBSUB_TOPIC
)

# ------------------------------
# Database Connection (Cloud SQL - Private IP)
# ------------------------------
def get_db_connection():
    """
    Creates a direct TCP connection to Cloud SQL instance using private IP
    Instance format example: myproject:us-central1:makeauto-sql
    """

    # Cloud SQL DSN (requires private IP enabled)
    dsn = (
        f"host={SQL_INSTANCE} "
        f"user={SQL_USER} "
        f"password={SQL_PASSWORD} "
        f"dbname={SQL_DB_NAME}"
    )

    return psycopg2.connect(dsn)

# ------------------------------
# IoT Payload Model
# ------------------------------
class IoTPayload(BaseModel):
    device_id: str
    temperature: float
    humidity: float
    timestamp: str  # ISO8601

# ------------------------------
# Health Endpoint
# ------------------------------
@app.get("/health")
def health():
    return {"status": "ok"}

# ------------------------------
# Ingest Endpoint
# ------------------------------
@app.post("/ingest")
def ingest(payload: IoTPayload):
    try:
        message_data = payload.dict()
        message_bytes = json.dumps(message_data).encode("utf-8")

        future = publisher.publish(topic_path, data=message_bytes)
        message_id = future.result()

        return {"status": "queued", "message_id": message_id}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
