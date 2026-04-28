# Azure Terraform Reference Architectures

Each folder is an independent Terraform project. Authenticate with an Azure principal that can create subscriptions resources, then set the variables required by each stack.

The architectures use Azure-native services:

- Front Door, Application Gateway, VM Scale Sets, Azure Database, and Azure Cache for Redis
- API Management, Azure Functions, and Cosmos DB
- AKS, Azure Container Registry, and Service Bus
- Event Hubs, ADLS Gen2, Data Factory, Synapse, and Power BI-ready outputs
- Traffic Manager, paired regional web tiers, Azure SQL failover groups, and GRS storage

## Production Engineering Add-ons

- GitHub Actions Terraform CI in `.github/workflows/terraform-ci.yml`.
- TFLint, Checkov, and OPA/Rego guardrail examples.
- Architecture diagrams, security notes, cost notes, observability guidance, and runbooks in `docs/`.
- Per-stack `terraform.tfvars.example` files.
- PowerShell task runner at `scripts/tf.ps1`.
