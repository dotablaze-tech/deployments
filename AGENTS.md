# AGENTS.md

Canonical instructions for AI agents in this repo. `CLAUDE.md` only imports
this file; edit this one. Layout, config schema and how to add apps or
environments: [README.md](README.md); chart details:
[charts/meowbot/README.md](charts/meowbot/README.md).

## Repo facts

- GitOps repo: ArgoCD's `dotablaze-tech-deployments` ApplicationSet reads
  `argocd/<env>/config.yaml` and deploys `charts/<name>` with
  `values.yaml` + `values-<env>.yaml`. Environments: `non`, `prd`.
- A merge to `main` is a deploy. Sync is automated (prune, self-heal).
- Only chart today: `meowbot` (image `dotablaze/meowbot`).

## Commands

Same checks as `.github/workflows/ci.yaml`:

```bash
helm lint charts/meowbot
helm template meowbot charts/meowbot -f charts/meowbot/values.yaml -f charts/meowbot/values-non.yaml >/dev/null
helm template meowbot charts/meowbot -f charts/meowbot/values.yaml -f charts/meowbot/values-prd.yaml >/dev/null
yq '.apps | length' argocd/non/config.yaml   # config sanity; CI also checks paths
```

## Release flow

- `dotablaze-tech/platform` CI pushes `appVersion` in
  `charts/meowbot/Chart.yaml` straight to `main` (commit
  `chore(meowbot): update app version to version X.Y.Z`). `image.tag` is empty
  in `values.yaml` and `values-non.yaml`, so non-prod follows `appVersion` and
  ArgoCD rolls it automatically.
- Prod is pinned by `image.tag` in `charts/meowbot/values-prd.yaml` as
  `X.Y.Z@sha256:<index digest>`. Never hand-edit it: `promote-prd.yml` opens
  the promotion PR on every appVersion bump (or by `workflow_dispatch`), and
  a code owner approves it once the version is healthy in non.
- Merging to `main` also runs `release.yaml` (chart-releaser publishes charts).
- A change is done when ArgoCD shows the app Synced and Healthy, not at green
  CI. Ask before anything that restarts prod or deletes data.

## Branches, commits, PRs

- Never work on or push to `main`; use a worktree. Branch
  `type/DOTA-N-kebab-case`, e.g. `docs/DOTA-10-add-agents-md`.
- Conventional Commits, atomic, rebased onto `origin/main`; no merge commits.
- Merges are rebase-merge only.
- Renovate here does not auto-merge: every update waits for review. The
  meowbot image is excluded from Renovate (first-party pin).
- PR title under 70 chars; body about 150 words: Why / Needs attention /
  Risk-rollout / Verified. Wait for green CI.
- AI attribution goes only in commit trailers (`Co-Authored-By`,
  `Assisted-by`), never in files or PR text. Org rules:
  [dotablaze-tech/.github CONTRIBUTING.md](https://github.com/dotablaze-tech/.github/blob/main/CONTRIBUTING.md).

## Secrets

Secrets come from ExternalSecrets (Vault / k8s secret store). Never commit
values or print a credential.
