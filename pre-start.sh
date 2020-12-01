#!/bin/sh

ytt -f /templates \
  --file-mark '**/*.sh:type=text-template' \
  --file-mark 'services.d/postgres_exporter/run.sh:path=services.d/postgres_exporter/run' \
  --output-files /etc
