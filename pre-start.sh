#!/usr/bin/with-contenv sh

set -e

ytt --data-value-yaml "config=$(cat /config.yml)" -f /templates \
  --file-mark '**/*.sh:type=text-template' \
  --file-mark '**/*.conf:type=text-template' \
  --file-mark '**/*.json:type=text-template' \
  --file-mark 'services.d/telegraf/run.sh:path=services.d/telegraf/run' \
  --output-files /etc
