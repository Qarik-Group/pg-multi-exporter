#!/bin/bash

echo "BECOMING STANDBY"

set -x

s6-svc -dO /var/run/s6/services/telegraf
s6-svc -dO /var/run/s6/services/telegraf_cpu
s6-svc -dO /var/run/s6/services/telegraf_disk
