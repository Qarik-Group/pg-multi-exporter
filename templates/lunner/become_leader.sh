#!/bin/bash

echo "BECOMING LEADER"

set -x

s6-svc -u /var/run/s6/services/telegraf
s6-svc -u /var/run/s6/services/telegraf_cpu
s6-svc -u /var/run/s6/services/telegraf_disk
