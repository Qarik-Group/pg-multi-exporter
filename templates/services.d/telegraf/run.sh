#!/bin/sh

export GOOGLE_APPLICATION_CREDENTIALS=/etc/telegraf/stackdriver_service_account.json

exec telegraf --config /etc/telegraf/telegraf.conf
