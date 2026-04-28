# Azure Microservices on AKS

Deploys AKS, Azure Container Registry, Service Bus topic/subscriptions for domain events, and Cosmos DB databases owned by `orders`, `users`, and `payments`.

Production notes:

- Application manifests and image pipelines are intentionally outside the stack.
- Azure RBAC for Kubernetes is enabled.
- ACR Premium is used for production registry features.
