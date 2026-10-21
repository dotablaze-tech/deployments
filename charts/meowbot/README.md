# meowbot Helm Chart

[![Chart Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdotablaze-tech%2Fdeployments%2Fmain%2Fcharts%2Fmeowbot%2FChart.yaml&query=%24.appVersion&prefix=v&label=Chart)](https://github.com/dotablaze-tech/deployments/blob/main/charts/meowbot/Chart.yaml)
[![Non Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdotablaze-tech%2Fdeployments%2Fmain%2Fcharts%2Fmeowbot%2FChart.yaml&query=%24.appVersion&prefix=v&label=Non)](https://github.com/dotablaze-tech/deployments/blob/main/charts/meowbot/values-non.yaml)
[![Prod Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdotablaze-tech%2Fdeployments%2Fmain%2Fcharts%2Fmeowbot%2Fvalues-prd.yaml&query=%24.image.tag&prefix=v&label=Prod)](https://github.com/dotablaze-tech/deployments/blob/main/charts/meowbot/values-prd.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This Helm chart is used to deploy the `meowbot` Discord bot on Kubernetes via Argo CD. It provides a customizable,
environment-specific configuration for managing runtime secrets, autoscaling, Gateway API routing, and service exposure.

> **Note**: `meowbot` is built using [bwmarrin/discordgo](https://github.com/bwmarrin/discordgo) and supports regex-based interactions, per-guild state, logging via `slog`, and slash commands.

---

## 📁 Layout

- `Chart.yaml` – Chart metadata and versioning
- `templates/` – Kubernetes manifests:
  - `deployment.yaml` – Discord bot deployment logic
  - `externalsecrets.yaml` – Secrets configuration (e.g., bot token)
  - `httproute.yaml` – Gateway API `HTTPRoute` attached to `platform-gateway` (rendered when `ingress.enabled`)
  - `service.yaml` – ClusterIP service on port 8080
  - `hpa.yaml` – Autoscaling settings
  - `serviceaccount.yaml` – Optional service account
  - `NOTES.txt`, `tests/` – Installation notes and connectivity test
- `values.yaml` – Base configuration
- `values-non.yaml`, `values-prd.yaml` – Environment-specific overrides

---

## 🚀 Deployment

Argo CD deploys this chart from the `dotablaze-tech-deployments` ApplicationSet (`argocd/<env>/config.yaml`):

| Env | Argo CD app                  | Namespace            | Values files                     |
|-----|------------------------------|----------------------|----------------------------------|
| non | `dotablaze-tech-meowbot-non` | `dotablaze-tech-non` | `values.yaml`, `values-non.yaml` |
| prd | `dotablaze-tech-meowbot-prd` | `dotablaze-tech-prd` | `values.yaml`, `values-prd.yaml` |

Image tag is `image.tag`, falling back to `appVersion` in `Chart.yaml`:

- **non** leaves `image.tag` empty. The apps release job (`tools/update-app.sh`) pushes each new `appVersion` to
  `main`, so non follows every release automatically.
- **prd** pins `image.tag` in `values-prd.yaml`. Promote by opening a PR that changes it.

To render or lint locally, from the repo root:

```bash
helm lint charts/meowbot -f charts/meowbot/values.yaml -f charts/meowbot/values-non.yaml
helm template meowbot charts/meowbot -f charts/meowbot/values.yaml -f charts/meowbot/values-non.yaml
```

To install by hand into a scratch cluster (the base file must come first so the env file overrides it):

```bash
helm upgrade --install meowbot charts/meowbot \
  -n dotablaze-tech-non \
  -f charts/meowbot/values.yaml -f charts/meowbot/values-non.yaml
```

Do not do this against the live `non` or `prd` namespaces; Argo CD self-heals and owns those releases.

### Secret reloads

`values-non.yaml` and `values-prd.yaml` set `deploymentAnnotations` with
`secret.reloader.stakater.com/reload: "<pg-secret>,<bot-secret>"` (for example `meowbot-pg-non,meowbot-non`). With Stakater Reloader running in the cluster, the Deployment restarts when either ExternalSecret-managed Secret changes. The names must
match the `secretName` values in `externalSecrets` and `envSecrets`. The annotation goes on the Deployment only, not on
pods.

---

## 📂 Path

This chart is located at:

```
charts/
└── meowbot/
    ├── Chart.yaml
    ├── values.yaml
    ├── values-non.yaml
    ├── values-prd.yaml
    └── templates/
        ├── deployment.yaml
        ├── externalsecrets.yaml
        ├── hpa.yaml
        ├── httproute.yaml
        ├── service.yaml
        ├── serviceaccount.yaml
        ├── _helpers.tpl
        ├── NOTES.txt
        └── tests/
            └── test-connection.yaml
```

---

## 🧠 Features

- 🧩 Slash commands & custom regex triggers
- 📡 Multi-guild support with persistent state
- 🔒 Secrets managed through External Secrets
- 📈 Autoscaling via HPA
- 🛡️ Minimal RBAC via ServiceAccount (optional)

---

## 📝 License

This chart is licensed under the [MIT License](https://opensource.org/licenses/MIT). See the `LICENSE` file for details.
