#!/usr/bin/with-contenv bash

set -e

args='--file-mark **/*.sh:type=text-template --file-mark **/*.conf:type=text-template --file-mark **/*.json:type=text-template --file-mark services.d/lunner/run.sh:path=services.d/lunner/run --file-mark services.d/telegraf_disk/run.sh:path=services.d/telegraf_disk/run --file-mark services.d/telegraf_cpu/run.sh:path=services.d/telegraf_cpu/run --file-mark services.d/telegraf/run.sh:path=services.d/telegraf/run --file-mark services.d/azure_metrics_exporter/run.sh:path=services.d/azure_metrics_exporter/run --file-mark services.d/aliyun_exporter/run.sh:path=services.d/aliyun_exporter/run --output-files /etc'

if [ -f /config-iaas.yml ]; then
  ytt -f /templates \
  --data-value "lunner_id=$(hostname)" \
  --data-value-yaml "config=$(cat /config.yml)" \
  --data-value-yaml "iaas_config=$(cat /config-iaas.yml)" \
  ${args}
else
  ytt -f /templates \
  --data-value "lunner_id=$(hostname)" \
  --data-value "id=$(hostname)"
  --data-value-yaml "config=$(cat /config.yml)" \
  ${args}
fi
