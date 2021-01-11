#!/bin/sh

export GOOGLE_APPLICATION_CREDENTIALS=/etc/telegraf/stackdriver_service_account.json

telegraf --config /etc/telegraf/telegraf_disk.conf
