#!/usr/bin/with-contenv bash

set -e

args='--file-mark **/*.sh:type=text-template --file-mark **/*.conf:type=text-template --file-mark **/*.json:type=text-template --file-mark services.d/telegraf/run.sh:path=services.d/telegraf/run --output-files /etc'

if [ -f /config-iaas.yml ]; then
  ytt -f /templates \
  --data-value-yaml "config=$(cat /config.yml)" \
  --data-value-yaml "iaas_config=$(cat /config-iaas.yml)" \
  ${args}
else
  ytt -f /templates \
  --data-value-yaml "config=$(cat /config.yml)" \
  ${args}
fi
