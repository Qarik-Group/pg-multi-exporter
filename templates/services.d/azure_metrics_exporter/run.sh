#!/bin/bash
(@ load("@ytt:data", "data") @)

(@ if hasattr(data.values.iaas_config, "azure"): @)

export AZURE_TENANT_ID="(@= data.values.iaas_config.azure.tenant_id @)"
export AZURE_CLIENT_ID="(@= data.values.iaas_config.azure.client_id @)"
export AZURE_CLIENT_SECRET="(@= data.values.iaas_config.azure.client_secret @)"

azure-metrics-exporter --enable-caching

(@ else: @)
s6-svc -dXO /var/run/s6/services/azure_metrics_exporter
(@ end @)