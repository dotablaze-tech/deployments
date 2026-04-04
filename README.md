# Deployments

[![Deploy Pages](https://github.com/dotablaze-tech/deployments/actions/workflows/release.yaml/badge.svg)](https://github.com/dotablaze-tech/deployments/actions/workflows/release.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docs](https://img.shields.io/badge/docs-github--pages-blue)](https://dotablaze-tech.github.io/deployments/)
[![meowbot Chart Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdotablaze-tech%2Fdeployments%2Fmain%2Fcharts%2Fmeowbot%2FChart.yaml&query=%24.appVersion&prefix=v&label=meowbot)](https://github.com/dotablaze-tech/deployments/blob/main/charts/meowbot/Chart.yaml)

GitOps deployment repository for the `dotablaze-tech` tenant on the Jdwlabs platform. ArgoCD reads this repo via the
`dotablaze-tech-deployments` ApplicationSet to deploy applications into tenant-owned namespaces.

## Repository Structure

```
deployments/
├── argocd/
│   ├── non/
│   │   └── config.yaml  # Defines apps for non-prod environment
│   └── prd/
│       └── config.yaml  # Defines apps for prod environment
└── charts/
    └── <chart-name>/
        ├── Chart.yaml
        ├── templates/
        ├── values.yaml        # Base values
        ├── values-non.yaml    # Non-prod overrides
        └── values-prd.yaml    # Prod overrides
```

## How It Works

The `dotablaze-deployments` ApplicationSet uses a matrix generator that:

1. Scans `argocd/*/config.yaml` (one file per environment)
2. Expands the `apps` array from each config file
3. Creates an ArgoCD Application for each entry, named `dotablaze-tech-<name>`

All apps use automated sync with prune, self-heal, `ServerSideApply`, and `PruneLast`.

## Config Schema

Each `argocd/<env>/config.yaml` contains:

```yaml
apps:
  - name: <app-name>                # Unique name for the application
    namespace: <tenant>-<ns>        # Must be a namespace the tenant owns
    chartPath: charts/<chart-name>  # Path to chart in the deployment repo
    syncWave: "0"                   # Default ordering (default: "0")
    valuesFiles:
      - values.yaml
      - values-<env>.yaml
```

| Field         | Required | Description                                                  |
|---------------|----------|--------------------------------------------------------------|
| `name`        | Yes      | Unique name for the application (used in ArgoCD Application) |
| `namespace`   | Yes      | Target namespace for deployment (must be owned by tenant)    |
| `chartPath`   | Yes      | Path to the Helm chart within the deployment repo            |
| `syncWave`    | No       | Sync wave for ordering (default: "0")                        |
| `valuesFiles` | yes      | List of values files to use (base + environment-specific)    |

## Adding a New App

1. Create the Helm chart under `charts/<name>/`
2. Add base `values.yaml` and per-environment `values-<env>.yaml` files
3. Add an entry to each relevant `argocd/<env>/config.yaml`
4. Commit and push to `main`

## Adding a New Environment

1. Create `argocd/<env>/config.yaml` with the app definitions
2. Add `values-<env>.yaml` files for each chart as needed
3. Ensure the namespace exists in the platform tenant config (`tenants/dotablaze-tech/tenant.yaml`)

## Environments

| Environment | Namespace            | Config                   |
|-------------|----------------------|--------------------------|
| non         | `dotablaze-tech-non` | `argocd/non/config.yaml  | 
| prd         | `dotablaze-tech-prd` | `argocd/prd/config.yaml` |

## Sync Wave Ordering

| Wave | Charts                                                    |
|------|-----------------------------------------------------------|
| 0    | secret-store (SecretStores + RBAC must exist before apps) |
| 1    | All application charts (default)                          |

## Prerequisites

The following must exist in the cluster before deploying:

- Tenant namespaces provisioned by the platform
- External Secrets Operator (ESO) installed
- Value accessible at `http://vault.vault.svc.cluster.local:8200`
- `vault-token` Kubernetes Secret in each app namespace
- cert-manager with `letsencrypt-prod` ClusterIssuer
- nginx ingress controller
- CNPG PostgreSQL clusters in the `database` namespace
