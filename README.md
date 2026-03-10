# forge-cloud-infrastructures
This repository manages our cloud infrastructure using Terraform, to provision and manage cloud infrastructure across multiple environments. The infrastructure is organised by region and environment to ensure clarity, consistency, and safe separation of resources.

## Repository Structure
```text
.
├── .github
│   └── workflows
│       └── terraform-ci.yml
├── eu-central-1
│   ├── staging
│   └── production
├── .gitignore
└── README.md

```
- `.github/workflows` contains the GitHub Actions workflows used for continuous integration.
- `eu-central-1` contains Terraform configurations grouped by environment which includes: staging, and production that represents separate deployment environments.

## Contribution Workflow
> **NOTE:** All Terraform changes in this repository must be made through a Pull Request. This is a strict requirement. Direct pushes are not allowed.

Terraform planning and application are handled automatically by Atlantis, which is integrated with this repository and operates exclusively on Pull Requests. As a result, any Terraform change that is not submitted via a Pull Request will be blocked not be planned or applied.

## How Infrastructure Changes Are Applied
1. You create a new branch from the appropriate base branch
2. You make your Terraform changes (`.tf` files only)
3. You open a Pull Request
4. Once the PR is opened:
      - GitHub Actions runs validation checks
      - Atlantis automatically runs `terraform plan`
5. Someone from the team will review the code and after review, then approval:
      - Atlantis runs by commenting `atlantis apply` directly from the PR

This workflow ensures that infrastructure changes are reviewed, validated, and applied in a safe and auditable way across all environments.
