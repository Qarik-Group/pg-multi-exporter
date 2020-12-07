#!/usr/bin/with-contenv sh

cat <<EOF > /templates/inputs.yml
#@data/values
---
influxdb:
  endpoint: "${INFLUXDB_ENDPOINT}"
EOF

ytt -f /templates \
  --file-mark '**/*.sh:type=text-template' \
  --file-mark '**/*.conf:type=text-template' \
  --file-mark 'services.d/postgres_exporter/run.sh:path=services.d/postgres_exporter/run' \
  --file-mark 'services.d/telegraf/run.sh:path=services.d/telegraf/run' \
  --output-files /etc
