import os
import json
import time
import psycopg2
from google.cloud import pubsub_v1

# -----------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------
SQL_USER = os.getenv("SQL_USER")
SQL_PASSWORD = os.getenv("SQL_PASSWORD")
SQL_DB_NAME = os.getenv("SQL_DB_NAME", "makeauto_db")
SQL_INSTANCE = os.getenv("SQL_INSTANCE_CONNECTION_NAME")

PUBSUB_SUBSCRIPTION = os.getenv("PUBSUB_SUBSCRIPTION")
PROJECT_ID = os.getenv("PROJECT_ID")

if not PROJECT_ID:
    raise RuntimeError("PROJECT_ID environment variable is required for Pub/Sub")

# -----------------------------------------------------------
# Pub/Sub Subscriber (Workload Identity)
# -----------------------------------------------------------
subscriber = pubsub_v1.SubscriberClient()
subscription_path = subscriber.subscription_path(PROJECT_ID, PUBSUB_SUBSCRIPTION)

# -----------------------------------------------------------
# Cloud SQL Database Connection
# -----------------------------------------------------------
def get_db_connection():
    """
    Direct TCP connection to Cloud SQL instance (private IP).
    """

    dsn = (
        f"host={SQL_INSTANCE} "
        f"user={SQL_USER} "
        f"password={SQL_PASSWORD} "
        f"dbname={SQL_DB_NAME}"
    )

    return psycopg2.connect(dsn)

# -----------------------------------------------------------
# Processing Function
# -----------------------------------------------------------
def process_message(message):
    """
    Callback for processing Pub/Sub messages.
    """

    try:
        payload = json.loads(message.data.decode("utf-8"))

        device_id = payload["device_id"]
        temperature = payload["temperature"]
        humidity = payload["humidity"]
        timestamp = payload["timestamp"]

        # Insert into Cloud SQL
        conn = get_db_connection()
        cur = conn.cursor()

        query = """
            INSERT INTO iot_readings (device_id, temperature, humidity, timestamp)
            VALUES (%s, %s, %s, %s)
        """

        cur.execute(query, (device_id, temperature, humidity, timestamp))
        conn.commit()

        cur.close()
        conn.close()

        print(f"Processed message for device {device_id}")
        message.ack()

    except Exception as e:
        print(f"Error processing message: {e}")
        message.nack()

# -----------------------------------------------------------
# Main Loop
# -----------------------------------------------------------
def main():
    print("Starting Processor Worker...")

    streaming_pull = subscriber.subscribe(subscription_path, callback=process_message)
    print(f"Listening on {subscription_path}...")

    try:
        while True:
            time.sleep(30)
    except KeyboardInterrupt:
        streaming_pull.cancel()
        print("Shutting down worker...")


if __name__ == "__main__":
    main()
