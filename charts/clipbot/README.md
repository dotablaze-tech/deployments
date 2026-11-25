# clipbot

Helm chart for the Twitch `!clip` service ([`apps/go/clipbot`](https://github.com/dotablaze-tech/apps/tree/main/apps/go/clipbot)).

- Host: `clipbot.<env>.jdwlabs.com` through `platform-gateway`.
- Secrets: one Vault entry shared by both envs, `kv/dotablaze-tech-clipbot`, with `clip_key`, `client_id`, `client_secret`,
  `refresh_token`, `broadcaster_id`.
- One replica only; cooldowns are in memory.
- `appVersion` is pushed by the apps release; prd pins the image digest through `promote-prd.yml`.
