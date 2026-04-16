These are repo-specific specialist profiles for LittleDownloader.

Pick the narrowest matching agent first:

- `telegram-flow.toml`: webhook intake, Telegram types, handlers, commands, and user-facing bot behavior.
- `download-pipeline.toml`: `DownloadJob`, `YtdlpDownloader`, quotas, storage layout, and notifications.
- `model-layer.toml`: `User`, `Chat`, `Download`, model contracts, scopes, enums, defaults, and model-level specs.
- `data-ops.toml`: migrations, rake tasks, reconciliation, and operational maintenance.
- `test-guardian.toml`: specs, regression coverage, and CI safety.
- `reviewer.toml`: code review, regression risks, and testing-gap analysis.

All specialists inherit the repo-wide guardrails from `AGENTS.md`.
The `.toml` files are the actual agent profiles; this README is only a quick index.
