#!/usr/bin/with-contenv sh

# STACKDRIVER_EXPORTER_GOOGLE_PROJECT_ID
# STACKDRIVER_EXPORTER_WEB_LISTEN_ADDRESS 9255

export GOOGLE_APPLICATION_CREDENTIALS=/etc/stackdriver_exporter/service_account.json

(@ load("@ytt:data", "data") @)
(@ if data.values.gcp.service_account: @)
stackdriver_exporter \
    --monitoring.metrics-type-prefixes "cloudsql.googleapis.com/database/cpu/utilization,cloudsql.googleapis.com/database/disk/read_ops_count,cloudsql.googleapis.com/database/disk/write_ops_count"
(@ else: @)
s6-svc -dXO /var/run/s6/services/stackdriver_exporter
(@ end @)
