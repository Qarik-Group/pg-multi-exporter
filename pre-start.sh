#!/usr/bin/with-contenv sh

set -e

echo "
#@data/values
---
influxdb:
  endpoint: '${INFLUXDB_ENDPOINT}'
gcp:
  service_account: '${GCP_SERVICE_ACCOUNT}'
" > /templates/inputs.yml

ytt -f /templates \
  --file-mark '**/*.sh:type=text-template' \
  --file-mark '**/*.conf:type=text-template' \
  --file-mark '**/*.json:type=text-template' \
  --file-mark 'services.d/postgres_exporter/run.sh:path=services.d/postgres_exporter/run' \
  --file-mark 'services.d/stackdriver_exporter/run.sh:path=services.d/stackdriver_exporter/run' \
  --file-mark 'services.d/telegraf/run.sh:path=services.d/telegraf/run' \
  --output-files /etc
