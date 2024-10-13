#!/usr/bin/env python
# -*- coding: utf-8 -*-

import yaml
import json 
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

def str_presenter(dumper, data):
    """configures yaml for dumping multiline strings
    Ref: https://stackoverflow.com/questions/8640959/how-can-i-control-what-scalar-form-pyyaml-uses-for-my-data
    """
    if data.count("\n") > 0:  # check for multiline string
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)

def read_yaml_file(file_name: str):
    try:
        with open(file_name, encoding="utf-8", mode="r") as yaml_file:
            return yaml.safe_load(yaml_file)
    except FileNotFoundError:
        raise

def write_yaml_file(file_name: str, data: any):
    yaml.add_representer(str, str_presenter)
    yaml.representer.SafeRepresenter.add_representer(
        str, str_presenter
    )  # to use with safe_dum
    with open(file_name, "w") as outfile:
        yaml.dump(data, outfile, default_flow_style=False, sort_keys=False)

def callback(message: pubsub_v1.subscriber.message.Message) -> None:
    try:
        data_str = message.data.decode("utf-8")
        data = json.loads(data_str)
        data.update({ 
            "messageStart" : datetime.now().isoformat()
        })
        now = datetime.now()
        log_time = now.strftime("%H:%M:%S")

        print(f"Received {log_time} {data}")

        batch = data.get("batch")
        eventData = data.get("eventData", {})
        eventNumber = data.get("eventNumber")
        # eventStart = data.get("eventStart")
        files = eventData.get("files", [])

        for file in files :
            data.update({ 
                "readStart" : datetime.now().isoformat()
            })
            content = read_yaml_file(f"./cs/{file}")
            data.update({ 
                "writeStart" : datetime.now().isoformat()
            })
            write_yaml_file(f"./ps/batch_{batch}_message_{eventNumber}_{file}", content)
            data.update({ 
                "writeEnd" : datetime.now().isoformat()
            })

        message.ack()

        data.update({ 
            "messageEnd" : datetime.now().isoformat()
        })
        log_time = now.strftime("%H:%M:%S")
        print(f"Acknowledged {log_time} {data}")

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
        # streaming_pull_future.result()
    except TimeoutError:
        streaming_pull_future.cancel()  # Trigger the shutdown.
        streaming_pull_future.result()  # Block until the shutdown is complete.

print("Message Queue - Finished")
