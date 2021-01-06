FROM golang:1.15 AS builder

COPY src /src
RUN mkdir /out

ENV CGO_ENABLED=0
ENV GOFLAGS="-mod=vendor"

RUN cd /src/telegraf && go build -o /out/telegraf ./cmd/telegraf
RUN cd /src/ytt && go build -o /out/ytt ./cmd/ytt

RUN cd /src/azure_metrics_exporter && go build -o /out/azure-metrics-exporter .



FROM python:3.8-alpine

RUN apk add --update --no-cache build-base libffi-dev libressl-dev

COPY src/aliyun_exporter /src/aliyun_exporter
RUN cd /src/aliyun_exporter && pip install -e .
RUN pip uninstall --yes werkzeug && pip install werkzeug==0.16.0

ADD https://github.com/just-containers/s6-overlay/releases/download/v2.1.0.2/s6-overlay-amd64-installer /tmp/
RUN chmod +x /tmp/s6-overlay-amd64-installer && /tmp/s6-overlay-amd64-installer /

COPY --from=builder /out/ /bin/


RUN apk --no-cache add curl bash

RUN mkdir -p /etc/cont-init.d/
ADD pre-start.sh /etc/cont-init.d/

ADD templates /templates

ENTRYPOINT ["/init"]
