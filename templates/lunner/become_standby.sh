#!/bin/bash
(@ load("@ytt:data", "data") @)

echo "BECOMING STANDBY"

set -x

s6-svc -dO /var/run/s6/services/telegraf
(@ if hasattr(data.values.iaas_config, "gcp"): @)
s6-svc -dO /var/run/s6/services/telegraf_cpu
s6-svc -dO /var/run/s6/services/telegraf_disk
(@ end @)

