# Azure Runbooks

## DR Failover

1. Confirm the primary region incident.
2. Validate Traffic Manager endpoint status.
3. Fail over Azure SQL failover group if needed.
4. Scale secondary VMSS capacity.
5. Verify application writes, reads, and background jobs.

## Restore Azure SQL

1. Choose point-in-time restore target.
2. Restore into a new database.
3. Validate schema and data.
4. Update application connection settings.

## Service Bus Backlog

1. Check active and dead-letter message counts.
2. Scale consumers.
3. Inspect poison messages.
4. Replay from dead-letter after fixing the consumer.
