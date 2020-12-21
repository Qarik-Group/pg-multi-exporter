#!/bin/bash
(@ load("@ytt:data", "data") @)

export AZURE_TENANT_ID="(@= data.values.iaas_config.azure.tenant_id @)"
export AZURE_CLIENT_ID="(@= data.values.iaas_config.azure.client_id @)"
export AZURE_CLIENT_SECRET="(@= data.values.iaas_config.azure.client_secret @)"

azure-metrics-exporter --debug