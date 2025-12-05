import atexit
import json
import os

import psycopg2
from fastapi import FastAPI, HTTPException
from google.cloud import pubsub_v1
from google.cloud.sql.connector import Connector, IPTypes
from pydantic import BaseModel

# ------------------------------
# Environment Variables (fail fast if missing)
# ------------------------------
PROJECT_ID = os.getenv("PROJECT_ID")
PUBSUB_TOPIC = os.getenv("PUBSUB_TOPIC")
SQL_USER = os.getenv("SQL_USER")
SQL_PASSWORD = os.getenv("SQL_PASSWORD")
SQL_DB_NAME = os.getenv("SQL_DB_NAME", "makeauto_db")
SQL_INSTANCE = os.getenv("SQL_INSTANCE_CONNECTION_NAME")

required_env = {
    "PROJECT_ID": PROJECT_ID,
    "PUBSUB_TOPIC": PUBSUB_TOPIC,
    "SQL_USER": SQL_USER,
    "SQL_PASSWORD": SQL_PASSWORD,
    "SQL_INSTANCE_CONNECTION_NAME": SQL_INSTANCE,
}

missing = [k for k, v in required_env.items() if not v]
if missing:
    raise RuntimeError(f"Missing required environment variables: {', '.join(missing)}")

# ------------------------------
# FastAPI App
# ------------------------------
app = FastAPI(title="makeAutomatic API Service")

# ------------------------------
# Pub/Sub Publisher (Workload Identity)
# ------------------------------
publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(PROJECT_ID, PUBSUB_TOPIC)

# ------------------------------
# Database Connection (Cloud SQL Connector)
# ------------------------------
connector = Connector()


def get_db_connection():
    """
    Creates a secure connection to Cloud SQL using the instance connection name.
    Instance format example: myproject:us-central1:makeauto-sql
    """

    return connector.connect(
        SQL_INSTANCE,
        "psycopg2",
        user=SQL_USER,
        password=SQL_PASSWORD,
        db=SQL_DB_NAME,
        ip_type=IPTypes.PRIVATE,
    )


atexit.register(connector.close)

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
