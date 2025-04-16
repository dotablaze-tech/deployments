# Dotablaze Platform Deployments

[![Deploy Pages](https://github.com/dotablaze-tech/deployments/actions/workflows/release.yaml/badge.svg)](https://github.com/dotablaze-tech/deployments/actions/workflows/release.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docs](https://img.shields.io/badge/docs-github--pages-blue)](https://dotablaze-tech.github.io/deployments/)

<details open>
<summary>📦 Helm Chart App Versions</summary>

[![meowbot Chart Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdotablaze-tech%2Fdeployments%2Fmain%2Fcharts%2Fmeowbot%2FChart.yaml&query=%24.appVersion&prefix=v&label=meowbot)](https://github.com/dotablaze-tech/deployments/blob/main/charts/meowbot/Chart.yaml)

</details>

---

## 🧭 Overview

This repository powers the GitOps-driven deployment layer for the Dotablaze Tech platform. It contains Helm charts,
ArgoCD `ApplicationSet` configurations, and environment-specific overrides to manage and automate deployments across
clusters.

---

## 📁 Repository Structure

```text
.
├── envs/                 📦 Environment-specific app configs (dev/staging/prod)
├── charts/               🛠️ Helm charts for Dotablaze Tech services
├── excluded/             🧪 Experimental or disabled charts
├── bootstrap.yaml        ⚙️ Main app configuration
├── LICENSE               📄 License information
└── README.md             📝 This file
```

---

## 🚀 Continuous Delivery with Argo CD

This repo is designed for use with Argo CD and `ApplicationSet`, which dynamically syncs Helm-based apps defined under
`envs/`.

### 🧾 Example `dev.yaml`

```yaml
apps:
  - appName: meowbot-dev
    helmPath: charts/core
    namespace: dev
    values:
      - values-dev.yaml
```

### 🔧 ApplicationSet Template (Bootstrap)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: dotablaze-deployments
  namespace: argocd
spec:
  goTemplate: true
  goTemplateOptions: [ "missingkey=error" ]
  generators:
    - matrix:
        generators:
          - git:
              repoURL: https://github.com/dotablaze-tech/deployments.git
              revision: main
              files:
                - path: envs/*
          - list:
              elementsYaml: "{{ .apps | toJson }}"
  template:
    metadata:
      name: "{{ .appName }}"
      annotations:
        argocd.argoproj.io/sync-wave: "1"
    spec:
      project: default
      source:
        repoURL: https://github.com/dotablaze-tech/deployments.git
        targetRevision: main
        path: "{{ .helmPath }}"
      destination:
        namespace: "{{ .namespace }}"
        server: https://kubernetes.default.svc
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
          - PruneLast=true
  templatePatch: |
    spec:
      source:
        helm:
          valueFiles:
            {{- toYaml .values | nindent 12 }}
```

---

## 🏗️ Adding a New Environment

1. Create a new file under `envs/`, e.g. `envs/staging.yaml`
2. Define your applications like so:

```yaml
apps:
  - appName: users-staging
    helmPath: charts/users
    namespace: staging
    values:
      - values-staging.yaml
```

3. Commit and push. ArgoCD will pick it up and deploy.

---

## 📦 Adding a New Helm Chart

1. Scaffold a chart:

   ```bash
   helm create charts/<app-name>
   ```

2. Customize `Chart.yaml`, `values.yaml`, and templates.
3. Add the chart to one or more environments in `envs/`.
4. Optionally add `values-dev.yaml`, `values-prod.yaml`, etc.
5. Test your chart locally:

   ```bash
   helm install --dry-run --debug ./charts/<app-name>
   ```

---

## 🧱 Related Repositories

### 🧩 [dotablaze-tech/platform](https://github.com/dotablaze-tech/platform)

Main monorepo for the Dotablaze platform, containing services, libraries, and tooling.

- 🚀 Micro frontends & backends
- 🧱 Angular, Golang, Java
- 🔗 Integrated with K8s and containerized deployments

---

## 🌍 Documentation

Deployment and chart documentation is available via GitHub Pages:

🔗 [**Dotablaze Deployments GitHub Pages**](https://dotablaze-tech.github.io/deployments/)

Auto-updated via 🚀 [GitHub Actions](https://github.com/dotablaze-tech/deployments/actions/workflows/release.yaml)

---

## 📄 License

Licensed under the [MIT License](https://opensource.org/licenses/MIT). See the `LICENSE` file for details.
