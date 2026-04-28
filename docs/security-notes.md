# Azure Security Notes

- Use GitHub OIDC with Azure federated credentials instead of client secrets.
- Prefer managed identities for workload access.
- Keep databases private and use private endpoints where possible.
- Enable Defender for Cloud recommendations in production subscriptions.
- Use Key Vault for runtime secrets.
- Use Azure Policy to enforce tags, allowed regions, and private networking.
- Keep diagnostic settings wired to Log Analytics.

## Policy-as-Code

The `policies/terraform.rego` file contains starter OPA rules for Terraform plan validation.

```powershell
terraform plan -out tfplan
terraform show -json tfplan > tfplan.json
conftest test tfplan.json -p policies
```
