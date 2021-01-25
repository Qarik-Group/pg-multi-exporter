# Pg-Multi-Exporter

a docker container that exports metrics of a running postgresql instance to influxdb (via embedded telegraf).
Most metrics are collected via the postgresql telegraf plugin. Aditional metrics that cannot be collected from a pg connection are collected via IaaS specific collection methods.

Supported IaaSes: GCP, AWS, Alicloud, Azure.

## Configuration

You must mount a file to the path `/config.yml` inside the container.

Config structure:

```
telegraf:
  debug: false ## optional

influxdb:
  endpoint: http://influxdb:8086       ## influxdb endpoint
  name_prefix: CF.pg-multi-exporter.   ## prefix for all the collected metrics

databases:                             ## Array with connection details for as many databases as is required
- host: postgres
  port: 5432
  username: postgres
  password: postgres
  #interval: 2m ##optional
```

Optionally an additional `/config-iaas.yml` can also be mounted to activate the IaaS specific metric collection:
```
# Uncomment the needed paramaters
# gcp:
#   interval: 1m ##optional
#   service_account:

# aws:
#   interval: 5m ##optional
#   region:
#   access_key:
#   secret_key:

# create application in azure and give it the "Monitoring Reader" role
# azure:
#   interval: 1m ##optional
#   tenant_id:
#   client_id:
#   client_secret:
#   subscription_id:
#   resource_group:

# alicloud:
#   interval: 5m ##optional
#   access_key_id:
#   access_key_secret:
#   region_id:
```


## Implementation details

The container is setup to run multiple processes (as needed) using the [s6 process manager](https://skarnet.org/software/s6/index.html) installed via the [s6-overlay](https://github.com/just-containers/s6-overlay) project.

Where possible all configuration is kept in the telegraf process but for some IaaSes an additional external collection process is required.

S6 initially runs a [`pre-start`](./pre-start.sh) hook that will use the [carvel-ytt](https://carvel.dev/ytt/) yaml templating tool to write out all files required to configure and run the desired processes.
The template files that get rendered at runtime are located in the repo under [./templates](./templates) and output to the `/etc` directory in the running container.

The source code of all the processes that are run in the container are vendored into this repo via [vendir](https://carvel.dev/vendir/) and built from source when creating the docker image ([`Dockerfile`](./Dockerfile)).

For high-availability one of the processes run by s6 is [lunner](https://github.com/bodymindarts/lunner).
It creates a and maintains a table in the first database configured in the `config.yml` by which it ensures that data will only be collected and exported from 1 container at a time (should there be multiple identically configured instances running).

## Differences in iaas metrics

While all metrics that can be collected via a connection to postgres will be identical regardless of IaaS the IaaS specific metrics vary slightly.
We have attempted to unify the received metrics as much as possible via renaming but some differences remain:

### Renamed metrics

CPU:
cpu_percentage (GCP, AWS, Alicloud, Azure)

MEMORY:
memory_percentage (Azure, GCP, Alicloud)
freeable_memory (AWS)

IOPS:
read_ops_count (GCP, AWS)
write_ops_count (GCP, AWS)
iops_percentage (Alicoud, Azure)

DISK:

storage_percentage (GCP, Azure, Alicloud)
free_storage_space (AWS)

CONNECTIONS:
active_connections (Azure)
failed_connections (Azure)
connections (AliCloud)

### GCP
name: database_cpu
fields: utilization

name: database_memory
fields: utilization

name: database_disk
fields: read_ops_count
        write_ops_count
        free disk space
        disk usage

### AWS
name: database
fields: cpu_utilization_average
        read_iops_average
        write_iops_average
        database_connections_average
        freeable_memory_average
        free_storage_space_average

### Azure
name: database
fields: cpu_percent
        memory_percent
        read_iops  (not-available in single server)
        write_iops (not-available in single server)
        storage_percentage


### Alicloud
name: database
fields: cpu         usage
        memory      usage
        iops        usage
        disk        usage rename to: disk usage/storage?
        connections usage
