# Deployments

[![Deploy Pages](https://github.com/dotablaze-tech/deployments/actions/workflows/release.yaml/badge.svg)](https://github.com/dotablaze-tech/deployments/actions/workflows/release.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docs](https://img.shields.io/badge/docs-github--pages-blue)](https://dotablaze-tech.github.io/deployments/)
[![meowbot Chart Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdotablaze-tech%2Fdeployments%2Fmain%2Fcharts%2Fmeowbot%2FChart.yaml&query=%24.appVersion&prefix=v&label=meowbot)](https://github.com/dotablaze-tech/deployments/blob/main/charts/meowbot/Chart.yaml)

GitOps deployment repository for the `dotablaze-tech` tenant on the [jdwlabs platform](https://github.com/jdwlabs/platform). ArgoCD reads this repo via
the
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

The `dotablaze-tech-deployments` ApplicationSet uses a matrix generator that:

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
    valueFiles:
      - values.yaml
      - values-<env>.yaml
```

| Field        | Required | Description                                                  |
|--------------|----------|--------------------------------------------------------------|
| `name`       | Yes      | Unique name for the application (used in ArgoCD Application) |
| `namespace`  | Yes      | Target namespace for deployment (must be owned by tenant)    |
| `chartPath`  | Yes      | Path to the Helm chart within the deployment repo            |
| `syncWave`   | No       | Sync wave for ordering (default: "0")                        |
| `valueFiles` | Yes      | List of values files to use (base + environment-specific)    |

## Adding a New App

1. Create the Helm chart under `charts/<name>/`
2. Add base `values.yaml` and per-environment `values-<env>.yaml` files
3. Add an entry to each relevant `argocd/<env>/config.yaml`
4. Open a PR to `main`; Argo CD syncs after it merges

## Adding a New Environment

1. Create `argocd/<env>/config.yaml` with the app definitions
2. Add `values-<env>.yaml` files for each chart as needed
3. Ensure the namespace exists in the platform tenant config (`tenants/dotablaze-tech/tenant.yaml`)

## Environments

| Environment | Namespace            | Config                   |
|-------------|----------------------|--------------------------|
| non         | `dotablaze-tech-non` | `argocd/non/config.yaml` | 
| prd         | `dotablaze-tech-prd` | `argocd/prd/config.yaml` |

## Promoting to prd

`prd` pins `image.tag` in `charts/<app>/values-prd.yaml` to `<tag>@sha256:<index digest>`, so a re-pushed tag cannot
change what prod runs. [`promote-prd.yml`](.github/workflows/promote-prd.yml) opens the PR that moves it:

- **Automatically** whenever a `Chart.yaml` changes on `main`, which is how the apps release lands a new
  `appVersion`. The PR stays open until a code owner approves it, so verify the version in `non` first.
- **By hand:** `gh workflow run promote-prd.yml -f app=meowbot [-f tag=1.0.6]`. Pass `tag=X.Y.Z@sha256:<digest>` to pin
  an exact build, e.g. to roll back.

The workflow resolves the digest with [`tools/resolve-image-digest.sh`](tools/resolve-image-digest.sh) and commits through
the API so the commit is signed. With the `RELEASE_APP_ID` / `RELEASE_APP_PRIVATE_KEY` secrets, a GitHub App opens the
PR and CI runs on it. Without them it falls back to `GITHUB_TOKEN`, whose PRs trigger no checks and cannot merge.

## Sync Wave Ordering

| Wave | Charts                 |
|------|------------------------|
| 1    | All application charts |

## Prerequisites

The following must exist in the cluster before deploying (all managed by [jdwlabs/platform](https://github.com/jdwlabs/platform)):

- Tenant namespaces provisioned by the platform
- External Secrets Operator (ESO) installed
- `vault` ClusterSecretStore (platform-managed, reads from Vault)
- `k8s-secret-store` ClusterSecretStore (platform-managed, reads from `database` namespace)
- cert-manager with `letsencrypt-prod` ClusterIssuer
- Gateway API gateway `platform-gateway` in the `nginx-gateway` namespace (charts attach an `HTTPRoute` to it)
- Stakater Reloader, if secret changes should restart pods (charts opt in with `secret.reloader.stakater.com/reload` annotations)
- CNPG PostgreSQL clusters in the `database` namespace

Secret stores are managed centrally by the platform - no per-tenant secret store setup is needed.

## Branch Protection

Rulesets live as code in [`.github/rulesets/`](.github/rulesets/). Edit the JSON, merge by PR, then apply from that
directory with an admin `gh` login:

```bash
./apply.sh --dry-run   # diff every export against live
./apply.sh             # apply; refuses changes that weaken protection without --allow-weakening
```

- **Baseline** (`main`): PR required, rebase merge only, linear history, no force-push or deletion, and the CI, scan
  and signature checks must pass.
- **PRD Promotion Review Gate** (`main`): code-owner review for the paths in [`CODEOWNERS`](.github/CODEOWNERS), which
  are prod values and `argocd/prd/`.
- **Branch Naming Convention**: branches start with `feat/`, `fix/`, `chore/`, `docs/` and similar, or `renovate/`.
- **Release Tag Protection**: tags cannot be deleted or moved.

Org admins bypass all rulesets. The apps release job's `appVersion` push depends on that bypass.
