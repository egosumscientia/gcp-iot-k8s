import os
import json
from google.cloud import pubsub_v1

# -------------------------------------------------------
# Environment
# -------------------------------------------------------
PUBSUB_TOPIC = os.getenv("PUBSUB_TOPIC")
PROJECT_ID = os.getenv("PROJECT_ID")

if not PROJECT_ID:
    raise RuntimeError("PROJECT_ID environment variable is required for Pub/Sub")

# -------------------------------------------------------
# Publisher Client (Workload Identity)
# -------------------------------------------------------
publisher = pubsub_v1.PublisherClient()

# Full topic path → projects/<project>/topics/<topic>
topic_path = publisher.topic_path(PROJECT_ID, PUBSUB_TOPIC)


# -------------------------------------------------------
# Publish Function
# -------------------------------------------------------
def publish_message(payload: dict) -> str:
    """
    Publishes a JSON payload to Pub/Sub.
    Returns the Pub/Sub message ID.
    """

    if not isinstance(payload, dict):
        raise ValueError("Payload must be a dictionary")

    try:
        message_bytes = json.dumps(payload).encode("utf-8")
        future = publisher.publish(topic_path, data=message_bytes)
        message_id = future.result()
        return message_id

    except Exception as e:
        raise RuntimeError(f"Failed to publish message: {e}")
