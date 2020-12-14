#!/usr/bin/with-contenv sh

set -e

if [ -f /config-iaas.yml ]; then
  iaas_arg='--data-value-yaml "iaas_config=$(cat /config-iaas.yml)"'
fi

ytt -f /templates \
  --data-value-yaml "config=$(cat /config.yml)" \
  ${iaas_arg} \
  --file-mark '**/*.sh:type=text-template' \
  --file-mark '**/*.conf:type=text-template' \
  --file-mark '**/*.json:type=text-template' \
  --file-mark 'services.d/telegraf/run.sh:path=services.d/telegraf/run' \
  --output-files /etc
