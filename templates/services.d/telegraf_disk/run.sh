#!/bin/sh
(@ load("@ytt:data", "data") @)
(@ if hasattr(data.values.iaas_config, "gcp"): @)

export GOOGLE_APPLICATION_CREDENTIALS=/etc/telegraf/stackdriver_service_account.json

exec telegraf --config /etc/telegraf/telegraf_disk.conf

(@ else: @)
s6-svc -dXO /var/run/s6/services/telegraf_disk
(@ end @)
