#!/bin/sh

gunicorn buckets.wsgi:application --bind 0.0.0.0:${APP_PORT}
