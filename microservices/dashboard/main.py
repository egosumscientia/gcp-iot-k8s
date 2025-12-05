import os

import psycopg2
from fastapi import FastAPI, HTTPException
from google.cloud.sql.connector import Connector, IPTypes

# -----------------------------------------------------------
# Environment Variables (fail fast if missing)
# -----------------------------------------------------------
SQL_USER = os.getenv("SQL_USER")
SQL_PASSWORD = os.getenv("SQL_PASSWORD")
SQL_DB_NAME = os.getenv("SQL_DB_NAME", "makeauto_db")
SQL_INSTANCE = os.getenv("SQL_INSTANCE_CONNECTION_NAME")

required_env = {
    "SQL_USER": SQL_USER,
    "SQL_PASSWORD": SQL_PASSWORD,
    "SQL_INSTANCE_CONNECTION_NAME": SQL_INSTANCE,
}

missing = [k for k, v in required_env.items() if not v]
if missing:
    raise RuntimeError(f"Missing required environment variables: {', '.join(missing)}")

# -----------------------------------------------------------
# FastAPI App
# -----------------------------------------------------------
app = FastAPI(title="makeAutomatic Dashboard Service")


# -----------------------------------------------------------
# DB Connection Function (Cloud SQL Connector)
# -----------------------------------------------------------
connector = Connector()


def get_db_connection():
    """
    Secure connection to Cloud SQL using instance connection name.
    """

    return connector.connect(
        SQL_INSTANCE,
        "psycopg2",
        user=SQL_USER,
        password=SQL_PASSWORD,
        db=SQL_DB_NAME,
        ip_type=IPTypes.PRIVATE,
    )


# -----------------------------------------------------------
# Health endpoint
# -----------------------------------------------------------
@app.get("/health")
def health():
    return {"status": "ok"}


# -----------------------------------------------------------
# Fetch last N records
# -----------------------------------------------------------
@app.get("/readings/latest")
def get_latest_readings(limit: int = 20):
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        query = """
            SELECT device_id, temperature, humidity, timestamp
            FROM iot_readings
            ORDER BY timestamp DESC
            LIMIT %s
        """

        cur.execute(query, (limit,))
        rows = cur.fetchall()

        cur.close()
        conn.close()

        results = []
        for r in rows:
            results.append({
                "device_id": r[0],
                "temperature": r[1],
                "humidity": r[2],
                "timestamp": r[3].isoformat() if hasattr(r[3], "isoformat") else str(r[3])
            })

        return {"count": len(results), "data": results}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# -----------------------------------------------------------
# Shutdown hook
# -----------------------------------------------------------
@app.on_event("shutdown")
def close_connector():
    connector.close()


# -----------------------------------------------------------
# Fetch all records (paginated)
# -----------------------------------------------------------
@app.get("/readings")
def get_readings(offset: int = 0, limit: int = 100):
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        query = """
            SELECT device_id, temperature, humidity, timestamp
            FROM iot_readings
            ORDER BY timestamp DESC
            OFFSET %s LIMIT %s
        """

        cur.execute(query, (offset, limit))
        rows = cur.fetchall()

        cur.close()
        conn.close()

        results = []
        for r in rows:
            results.append({
                "device_id": r[0],
                "temperature": r[1],
                "humidity": r[2],
                "timestamp": r[3].isoformat() if hasattr(r[3], "isoformat") else str(r[3])
            })

        return {"offset": offset, "limit": limit, "data": results}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
