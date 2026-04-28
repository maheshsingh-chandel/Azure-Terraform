param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("fmt", "init", "validate", "plan", "scan")]
  [string] $Action,

  [string] $Directory = "."
)

$ErrorActionPreference = "Stop"
$ConfigPath = Join-Path (Split-Path $PSScriptRoot -Parent) ".tflint.hcl"
Push-Location $Directory

try {
  switch ($Action) {
    "fmt" { terraform fmt -recursive }
    "init" { terraform init }
    "validate" {
      terraform init -backend=false
      terraform validate
    }
    "plan" {
      terraform init
      terraform plan
    }
    "scan" {
      tflint --init --config $ConfigPath
      tflint --config $ConfigPath
      checkov -d .
    }
  }
}
finally {
  Pop-Location
}
