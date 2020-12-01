FROM golang AS builder

COPY src /src
RUN mkdir /out

ENV CGO_ENABLED=0
ENV GOFLAGS="-mod=vendor"

RUN cd /src/exporter_exporter && go build -o /out/exporter_exporter .
RUN cd /src/postgres_exporter && go build -o /out/postgres_exporter ./cmd/postgres_exporter

FROM alpine
RUN apk --no-cache add s6
COPY --from=builder /out/ /bin/


