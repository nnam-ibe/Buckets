#!/bin/sh

gunicorn buckets.wsgi:application --bind 0.0.0.0:${BUCKETS_APP_PORT}
