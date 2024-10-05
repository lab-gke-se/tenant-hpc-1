#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
from concurrent import futures
from typing import Callable
from datetime import datetime
from json import loads, dumps
from base64 import b64decode
from os import getenv

from google.cloud import logging as gclogger
from google.cloud.logging.handlers import StructuredLogHandler
from google.cloud.logging_v2.handlers import setup_logging
from google.cloud import pubsub_v1

client = gclogger.Client()
client.setup_logging()
handler = StructuredLogHandler()
setup_logging(handler)

logging.getLogger().setLevel(logging.INFO)
logging.basicConfig(
    format="%(asctime)s [%(threadName)-0.12s] [%(levelname)-0.7s]  %(message)s"
)

def get_callback(
    publish_future: pubsub_v1.publisher.futures.Future, data: str
) -> Callable[[pubsub_v1.publisher.futures.Future], None]:
    def callback(publish_future: pubsub_v1.publisher.futures.Future) -> None:
        try:
            # Wait 60 seconds for the publish call to succeed.
            publish_future.result(timeout=60)
        except futures.TimeoutError:
            print(f"Publishing {data} timed out.")

    return callback

def message_handler(message):
    try:

        project_id = "lab-gke-se"
        topic_id = "hpc-1-messages"

        publisher = pubsub_v1.PublisherClient()
        topic_path = publisher.topic_path(project_id, topic_id)
        publish_futures = []

        batch = message.get("batch", 0)
        batchSize = message.get("batchSize", 0)
        eventData = message.get("eventData", {})

        for i in range(batchSize):
            message.update({ 
                "messageType": "event",
                "eventNumber": i+1,
                "eventStart": datetime.now().isoformat(),
                "eventData" : eventData
            })

            # logging.info( "message", extra={"json_fields": message})

            message_str = dumps(message)
            # print(f"data_str {message_str}")
            # When you publish a message, the client returns a future.
            publish_future = publisher.publish(topic_path, message_str.encode("utf-8"))
            # Non-blocking. Publish failures are handled in the callback function.
            publish_future.add_done_callback(get_callback(publish_future, message_str))
            publish_futures.append(publish_future)

        futures.wait(publish_futures, return_when=futures.ALL_COMPLETED)

        logging.info(f"message batch {batch} published")
    
    except Exception as error:
        logging.error(error)
        raise


def event_handler(event, context):
    try:
        data_str = b64decode(event["data"]).decode("utf-8")
        logging.info("trigger", extra={"json_fields": data_str })
        data = loads(data_str)
        message_handler(data)
        return '', 200
    
        # print(f"result {result}")
        # logging.info("result", extra={"json_fields": result })
    except Exception as error:
        logging.error(error)
        raise
