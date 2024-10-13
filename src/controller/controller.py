"""Publishes multiple messages to a Pub/Sub topic with an error handler."""

from json import dumps

from concurrent import futures
from google.cloud import pubsub_v1
from typing import Callable
from base64 import b64encode
from datetime import datetime

project_id = "lab-gke-se"
topic_id = "hpc-1-controller"

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(project_id, topic_id)
publish_futures = []


def get_callback(
    publish_future: pubsub_v1.publisher.futures.Future, data: str
) -> Callable[[pubsub_v1.publisher.futures.Future], None]:
    def callback(publish_future: pubsub_v1.publisher.futures.Future) -> None:
        try:
            # Wait 60 seconds for the publish call to succeed.
            print(publish_future.result(timeout=60))
        except futures.TimeoutError:
            print(f"Publishing {data} timed out.")

    return callback

# Create two large files and put them in the cloud storage bucket. 

batches   = 1000
batchSize = 1000
eventData = {
    "files": [
        "reference-1.yaml", 
        "reference-2.yaml", 
    ]
}

for i in range(batches):

    data = {
        "messageType": "batch",
        "batches": batches,
        "batch": i+1,
        "batchSize": batchSize, 
        "batchStart" : datetime.now().isoformat(),
        "eventData": eventData
    }

    data_str = dumps(data)
    print(f"data_str {data_str}")
    # When you publish a message, the client returns a future.
    data_str_encoded = data_str.encode("utf-8")
    publish_future = publisher.publish(topic_path, data_str.encode("utf-8"))
    print(f"data_str_encoded {data_str_encoded}")
    # Non-blocking. Publish failures are handled in the callback function.
    publish_future.add_done_callback(get_callback(publish_future, data_str))
    publish_futures.append(publish_future)

# Wait for all the publish futures to resolve before exiting.
futures.wait(publish_futures, return_when=futures.ALL_COMPLETED)

print(f"Published messages with error handler to {topic_path}.")
