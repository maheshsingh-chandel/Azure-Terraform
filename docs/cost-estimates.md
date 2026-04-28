# Azure Cost Notes

Major cost drivers:

- AKS nodes and load balancers.
- Application Gateway WAF v2.
- Azure Database high availability.
- Redis Premium.
- Synapse dedicated SQL pool.
- Cross-region DR and GRS storage.

Optimization ideas:

- Use Consumption Functions for idle APIs.
- Pause Synapse SQL pools outside analytics windows.
- Downsize non-prod VMSS and database SKUs.
- Add Azure Budget alerts by resource group.
