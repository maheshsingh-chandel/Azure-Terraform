# Azure Multi-Region DR

Deploys paired regional web tiers behind Traffic Manager, Azure SQL primary/secondary servers with an automatic failover group, and GRS storage.

Production notes:

- Traffic Manager monitors HTTP `/` and prioritizes the primary endpoint.
- Azure SQL failover group provides database failover across regions.
- Use Azure Front Door instead of Traffic Manager when you need L7 global routing, WAF, and edge acceleration.
