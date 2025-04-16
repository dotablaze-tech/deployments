# meowbot Helm Chart

[![Chart Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdotablaze-tech%2Fdeployments%2Fmain%2Fcharts%2Fmeowbot%2FChart.yaml&query=%24.appVersion&prefix=v&label=Chart)](https://github.com/dotablaze-tech/deployments/blob/main/charts/meowbot/Chart.yaml)
[![Dev Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdotablaze-tech%2Fdeployments%2Fmain%2Fcharts%2Fmeowbot%2FChart.yaml&query=%24.appVersion&prefix=v&label=Chart)](https://github.com/dotablaze-tech/deployments/blob/main/charts/meowbot/values-dev.yaml)
[![Prod Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdotablaze-tech%2Fdeployments%2Fmain%2Fcharts%2Fmeowbot%2Fvalues-prd.yaml&query=%24.image.tag&prefix=v&label=Prod)](https://github.com/dotablaze-tech/deployments/blob/main/charts/meowbot/values-prd.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This Helm chart is used to deploy the `meowbot` Discord bot on Kubernetes via Argo CD. It provides a customizable,
environment-specific configuration for managing runtime secrets, autoscaling, ingress, and service exposure.

> **Note**: `meowbot` is built using [bwmarrin/discordgo](https://github.com/bwmarrin/discordgo) and supports regex-based interactions, per-guild state, logging via `slog`, and slash commands.

---

## 📁 Layout

- `Chart.yaml` – Chart metadata and versioning
- `templates/` – Kubernetes manifests:
  - `deployment.yaml` – Discord bot deployment logic
  - `externalsecrets.yaml` – Secrets configuration (e.g., bot token)
  - `ingress.yaml`, `service.yaml` – Exposure options (if needed)
  - `hpa.yaml` – Autoscaling settings
  - `serviceaccount.yaml` – Optional service account
  - `NOTES.txt`, `tests/` – Installation notes and connectivity test
- `values.yaml` – Base configuration
- `values-dev.yaml`, `values-prd.yaml` – Environment-specific overrides

---

## 🚀 Deployment

This chart is deployed by Argo CD using an `ApplicationSet` generator that maps environments to values files.

To deploy manually for testing:

```bash
helm upgrade --install meowbot ./meowbot -f values-dev.yaml
```

To uninstall:

```bash
helm uninstall meowbot
```

---

## 📂 Path

This chart is located at:

```
charts/
└── meowbot/
    ├── Chart.yaml
    ├── values.yaml
    ├── values-dev.yaml
    ├── values-prd.yaml
    └── templates/
        ├── deployment.yaml
        ├── externalsecrets.yaml
        ├── hpa.yaml
        ├── ingress.yaml
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
