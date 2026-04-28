# Azure Three-Tier Web

Deploys Application Gateway WAF, a Linux VM Scale Set across zones, Azure Database for MySQL Flexible Server with zone-redundant HA, and Azure Cache for Redis Premium.

Production notes:

- Add Azure Front Door in front of Application Gateway when global edge acceleration is required.
- VM password auth is enabled to keep this stack self-contained; switch to SSH keys or Azure AD login in hardened environments.
- MySQL is private via delegated subnet and private DNS.
