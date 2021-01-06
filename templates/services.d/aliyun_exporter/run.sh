#!/bin/bash
(@ load("@ytt:data", "data") @)

(@ if hasattr(data.values.iaas_config, "alicloud"): @)
export PATH=${PATH}:/usr/local/bin

aliyun-exporter -c /etc/aliyun_exporter/config.yml

(@ else: @)
s6-svc -dXO /var/run/s6/services/aliyun_exporter
(@ end @)
