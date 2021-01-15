FROM golang:1.15 AS go-builder

COPY src /src
RUN mkdir /out

ENV CGO_ENABLED=0
ENV GOFLAGS="-mod=vendor"

RUN cd /src/telegraf && go build -o /out/telegraf ./cmd/telegraf
RUN cd /src/ytt && go build -o /out/ytt ./cmd/ytt

RUN cd /src/azure_metrics_exporter && go build -o /out/azure-metrics-exporter .


FROM clux/muslrust:stable AS rust-builder
  COPY src /src
  WORKDIR /src/lunner
  RUN cargo build --release

FROM python:3.8 AS py-builder

COPY src/aliyun_exporter /src/aliyun_exporter
RUN pip install pyinstaller
RUN pip install prometheus-client aliyun-python-sdk-cms==6.0.13 aliyun-python-sdk-core-v3==2.13.3 pyyaml ratelimiter flask cachetools aliyun-python-sdk-ecs==4.16.5 aliyun-python-sdk-rds==2.3.2 aliyun-python-sdk-r-kvstore==2.0.5 werkzeug

RUN sed -i 's/werkzeug.wsgi/werkzeug.middleware.dispatcher/g' /src/aliyun_exporter/aliyun_exporter/web.py

RUN cd /src/aliyun_exporter && pyinstaller -F --name aliyun-exporter --distpath=/out aliyun_exporter/__main__.py


FROM ubuntu:20.04
# FROM python:3.8-alpine

# RUN apk add --update --no-cache build-base libffi-dev libressl-dev

# COPY src/aliyun_exporter /src/aliyun_exporter
# RUN cd /src/aliyun_exporter && pip install -e .
# RUN pip uninstall --yes werkzeug && pip install werkzeug==0.16.0

ADD https://github.com/just-containers/s6-overlay/releases/download/v2.1.0.2/s6-overlay-amd64-installer /tmp/
RUN chmod +x /tmp/s6-overlay-amd64-installer && /tmp/s6-overlay-amd64-installer /

COPY --from=go-builder /out/ /bin/
COPY --from=rust-builder /src/lunner/target/x86_64-unknown-linux-musl/release/lunner /bin/
COPY --from=py-builder /out/ /bin/

# RUN apk --no-cache add curl bash

RUN mkdir -p /etc/cont-init.d/
ADD pre-start.sh /etc/cont-init.d/

ADD templates /templates

ENTRYPOINT ["/init"]
