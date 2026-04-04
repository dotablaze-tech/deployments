# secret-store Helm Chart

[![Chart Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdotablaze-tech%2Fdeployments%2Frefs%2Fheads%2Fmain%2Fcharts%2Fsecret-store%2FChart.yaml&query=%24.appVersion&prefix=v&label=Chart)](https://github.com/dotablaze-tech/deployments/blob/main/charts/secret-store/Chart.yaml)
[![Non Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdotablaze-tech%2Fdeployments%2Frefs%2Fheads%2Fmain%2Fcharts%2Fsecret-store%2FChart.yaml&query=%24.appVersion&prefix=v&label=Non)](https://github.com/dotablaze-tech/deployments/blob/main/charts/secret-store/values-non.yaml)
[![Prod Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdotablaze-tech%2Fdeployments%2Frefs%2Fheads%2Fmain%2Fcharts%2Fsecret-store%2FChart.yaml&query=%24.appVersion&prefix=v&label=Prod)](https://github.com/dotablaze-tech/deployments/blob/main/charts/secret-store/values-prd.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This Helm chart deploys namespace-scoped SecretStores (Vault and Kubernetes-backed) and the RBAC required for the External Secrets Operator. It is deployed at sync wave 0 so that SecretStores exist before application charts that depend on them.

## Layout

- `Chart.yaml` – Chart metadata and versioning
- `templates/` – Kubernetes manifests:
    - `k8s-secretstore.yaml` – SecretStore using native K8s secrets
    - `vault-secretstore.yaml` – SecretStore backed by Vault
    - `clusterrole.yaml`, `clusterrolebinding.yaml` – RBAC setup
    - `serviceaccount.yaml` – Service account for workload identity
- `values.yaml` – Base configuration
- `values-*.yaml` – Environment-specific overrides

## Deployment

Argo CD applies this chart using the appropriate `values-*.yaml` for each environment.

To test locally:

```bash
helm upgrade --install secret-store ./secret-store -f values-non.yaml
```

To remove:

```bash
helm uninstall secret-store
```
