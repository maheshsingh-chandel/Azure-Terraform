# Azure Remote State

Create a dedicated resource group, storage account, and private container for Terraform state.

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "REPLACEWITHSTATEACCOUNT"
    container_name       = "tfstate"
    key                  = "azure/STACK_NAME/terraform.tfstate"
  }
}
```

Recommended controls:

- Storage account soft delete and versioning.
- Private endpoint for state access in production.
- RBAC scoped to CI/CD identities and platform administrators.
