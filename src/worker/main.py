#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import random
import time
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
        logging.info(f"Processing batch {message['batch']} message {message['eventNumber']} of {message['batchSize']}", extra={"json_fields": message})
        delay = random.randrange(10)
        time.sleep(delay)
        logging.info(f"Processed  batch {message['batch']} message {message['eventNumber']} of {message['batchSize']}", extra={"json_fields": message})
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
    except Exception as error:
        logging.error(error)
        raise
