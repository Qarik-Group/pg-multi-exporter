#!/bin/bash
(@ load("@ytt:data", "data") @)

(@ if hasattr(data.values.iaas_config, "azure"): @)

azure-metrics-exporter --config.file=/etc/azure_exporter/config.yml

(@ else: @)
s6-svc -dXO /var/run/s6/services/azure_metrics_exporter
(@ end @)