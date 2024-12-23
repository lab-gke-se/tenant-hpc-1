#!/usr/bin/env python
# -*- coding: utf-8 -*-

# import yaml
import json 
import random

from math import factorial
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

# def str_presenter(dumper, data):
#     """configures yaml for dumping multiline strings
#     Ref: https://stackoverflow.com/questions/8640959/how-can-i-control-what-scalar-form-pyyaml-uses-for-my-data
#     """
#     if data.count("\n") > 0:  # check for multiline string
#         return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
#     return dumper.represent_scalar("tag:yaml.org,2002:str", data)

# def read_yaml_file(file_name: str):
#     try:
#         with open(file_name, encoding="utf-8", mode="r") as yaml_file:
#             return yaml.safe_load(yaml_file)
#     except FileNotFoundError:
#         raise

# def write_yaml_file(file_name: str, data: any):
#     yaml.add_representer(str, str_presenter)
#     yaml.representer.SafeRepresenter.add_representer(
#         str, str_presenter
#     )  # to use with safe_dum
#     with open(file_name, "w") as outfile:
#         yaml.dump(data, outfile, default_flow_style=False, sort_keys=False)

def callback(pubsub_message: pubsub_v1.subscriber.message.Message) -> None:
    try:
        message_str = pubsub_message.data.decode("utf-8")
        message = json.loads(message_str)
        timings = message.get("timings")
        timings["message read"] = datetime.now().isoformat()

        now = datetime.now()
        log_time = now.strftime("%H:%M:%S")
        print(f"Received {log_time} {message}")

        batch = message.get("batch")
        actions = message.get("actions", {})
        num = message.get("message")

        actions = message.get("actions")
        for action in actions:

            command = list(action.keys())[0]

            match command:
                case "read files":
                    for file in action[command]:
                        # Note: might want to do timings for file open and file read
                        with open(file, encoding="utf-8", mode="r") as file:
                            content = file.read()
                        timings[f"read file {file}"] = datetime.now().isoformat()
                case "calculate":
                    result = factorial(random.randrange(0,100))
                    timings[f"calculated {result}"] = datetime.now().isoformat()
                case "write message":
                    # result = write_message()
                    timings["writing message"] = datetime.now().isoformat()
                case other:
                    timings["unknown command"] = datetime.now().isoformat()

        pubsub_message.ack()

        timings["message finished"] = datetime.now().isoformat()

        log_time = now.strftime("%H:%M:%S")
        print(f"Acknowledged {log_time} {message}")

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
