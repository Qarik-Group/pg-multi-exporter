#!/bin/bash
(@ load("@ytt:data", "data") @)

echo "BECOMING LEADER"

set -x

s6-svc -u /var/run/s6/services/telegraf
(@ if hasattr(data.values.iaas_config, "gcp"): @)
s6-svc -u /var/run/s6/services/telegraf_cpu
s6-svc -u /var/run/s6/services/telegraf_disk
(@ end @)
