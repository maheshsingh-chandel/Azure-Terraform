# Azure Serverless API

Deploys API Management Consumption tier, Azure Functions Consumption, Application Insights, and Cosmos DB serverless.

Production notes:

- The starter function uses function-level auth. Add APIM policies, managed identity access, or Entra ID auth for real workloads.
- Cosmos DB serverless is enabled for idle-cost friendly API backends.
- Replace the default publisher email before production deployment.
