FROM golang:1.15 AS builder

COPY src /src
RUN mkdir /out

ENV CGO_ENABLED=0
ENV GOFLAGS="-mod=vendor"

RUN cd /src/exporter_exporter && go build -o /out/exporter_exporter .
RUN cd /src/postgres_exporter && go build -o /out/postgres_exporter ./cmd/postgres_exporter
RUN cd /src/ytt && go build -o /out/ytt ./cmd/ytt

FROM alpine

ADD https://github.com/just-containers/s6-overlay/releases/download/v2.1.0.2/s6-overlay-amd64-installer /tmp/
RUN chmod +x /tmp/s6-overlay-amd64-installer && /tmp/s6-overlay-amd64-installer /

COPY --from=builder /out/ /bin/

RUN apk --no-cache add curl

RUN mkdir -p /etc/cont-init.d/
ADD pre-start.sh /etc/cont-init.d/

ADD templates /templates

ENTRYPOINT ["/init"]
