#!/usr/bin/with-contenv sh

export DATA_SOURCE_NAME="postgres://${PG_USERNAME}:${PG_PASSWORD}@${PG_HOST}:${PG_PORT}/postgres?sslmode=${PG_SSL_MODE}"

postgres_exporter --log.level=debug --extend.query-path '/etc/postgres_exporter/queries.yml'
