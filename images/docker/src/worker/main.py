#!/usr/bin/env python
# -*- coding: utf-8 -*-

from concurrent.futures import TimeoutError
from datetime import datetime
from google.cloud import pubsub_v1

project_id = "lab-gke-se"
subscription_id = "hpc-1-messages"

print("Message Queue - Processing")

timeout = 120

subscriber = pubsub_v1.SubscriberClient()
# The `subscription_path` method creates a fully qualified identifier
# in the form `projects/{project_id}/subscriptions/{subscription_id}`
subscription_path = subscriber.subscription_path(project_id, subscription_id)

def callback(message: pubsub_v1.subscriber.message.Message) -> None:
    try:
        data = message.data.decode("utf-8")
        now = datetime.now()
        log_time = now.strftime("%H:%M:%S")
        print(f"Received {log_time} {data}")
        message.ack()
    except Exception as error:
        raise

streaming_pull_future = subscriber.subscribe(subscription_path, callback=callback)
print(f"Listening for messages on {subscription_path}..\n")

# Wrap subscriber in a 'with' block to automatically call close() when done.
with subscriber:
    try:
        # When `timeout` is not set, result() will block indefinitely,
        # unless an exception is encountered first.
        streaming_pull_future.result(timeout=timeout)
    except TimeoutError:
        streaming_pull_future.cancel()  # Trigger the shutdown.
        streaming_pull_future.result()  # Block until the shutdown is complete.

print("Message Queue - Finished")
