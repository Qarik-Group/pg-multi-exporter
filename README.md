# differences in iaas metrics

## Renamed metrics

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

## GCP
name: database_cpu
fields: utilization

name: database_memory
fields: utilization

name: database_disk
fields: read_ops_count
        write_ops_count
        free disk space
        disk usage

## AWS
### i think we only need average (configurable in telegraph.conf)
name: database
fields: cpu_utilization_average
        read_iops_average
        write_iops_average
        database_connections_average
        freeable_memory_average
        free_storage_space_average

## Azure
name: database
fields: cpu_percent
        memory_percent
        read_iops  (not-available in single server)
        write_iops (not-available in single server)
        storage_percentage


## Alicloud
name: database
fields: cpu         usage
        memory      usage
        iops        usage
        disk        usage rename to: disk usage/storage?
        connections usage
