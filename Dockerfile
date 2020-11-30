FROM golang AS builder

COPY src /src
RUN mkdir /out

RUN cd /src/exporter_exporter && CGO_ENABLED=0 go build -mod vendor -o /out/exporter_exporter .


FROM alpine
RUN apk --no-cache add s6
COPY --from=builder /out/ /bin/