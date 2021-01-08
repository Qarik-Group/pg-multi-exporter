# differences in iaas metrics

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
        cpu_utilization_maximum
        cpu_utilization_minimum
        cpu_utilization_sum
        read_iops_average
        read_iops_maximum
        read_iops_minimum
        read_iops_sum
        write_iops_average
        write_iops_maximum
        write_iops_minimum
        write_iops_sum
        database_connections_average
        database_connections_maximum
        database_connections_minimum
        database_connections_sum
        freeable_memory_average
        freeable_memory_maximum
        freeable_memory_minimum
        freeable_memory_sum
        free_storage_space_average
        free_storage_space_maximum
        free_storage_space_minimum
        free_storage_space_sum

## Azure
name: database
fields: cpu
        memory
        read_iops
        write_iops
        storage


## Alicloud
name: database
fields: cpu         usage
        memory      usage
        iops        usage
        disk        usage rename to: disk usage/storage?
        connections usage