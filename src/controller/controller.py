"""Publishes multiple messages to a Pub/Sub topic with an error handler."""

import os

from json import dumps
from concurrent import futures
from google.cloud import pubsub_v1
from typing import Callable
from datetime import datetime
from file_helper import read_yaml_file

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

message = read_yaml_file("message.yaml")
batches = message.setdefault("batches", 1)
messages = message.setdefault("messages", 1)

for i in range(batches):

    message.update({
        "batch": i+1,
        "message" : 0
    })
    timings = message.setdefault("timings", {})
    timings["batch started"] = datetime.now().isoformat()

    print(f"message : {message}")
    message_str = dumps(message)
    print(f"message_str : {message_str}")
    message_str_encoded = message_str.encode("utf-8")

    publish_future = publisher.publish(topic_path, message_str.encode("utf-8"))
    print(f"message_str_encoded {message_str_encoded}")
    # Non-blocking. Publish failures are handled in the callback function.
    publish_future.add_done_callback(get_callback(publish_future, message_str))
    publish_futures.append(publish_future)

# Wait for all the publish futures to resolve before exiting.
futures.wait(publish_futures, return_when=futures.ALL_COMPLETED)

print(f"Published messages with error handler to {topic_path}.")
