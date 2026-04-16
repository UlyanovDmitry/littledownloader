# LittleDownloader Agents Guide

This repository is a Rails 8.1 application for a self-hosted Telegram bot that downloads media with `yt-dlp`, stores files on local disk, and tracks metadata in PostgreSQL.

Use this file as the default operating guide for Codex agents working in this repo. Prefer the focused profiles in `.codex/agents/*.toml` when a task clearly belongs to one subsystem.

## Architecture Snapshot

- Entry point: Telegram webhook at `POST /telegram/webhook/:secret` in `app/controllers/telegram/webhooks_controller.rb`.
- Update fan-out: raw Telegram payloads are deduplicated in cache, then enqueued into `TelegramUpdateJob`.
- Telegram domain: parsing lives in `app/services/telegram/types/*`, behavior in `app/services/telegram/handlers/*`.
- Download pipeline: `DownloadJob` orchestrates quota checks, `YtdlpDownloader`, result persistence, and user/admin notifications.
- Persistence: core models are `User`, `Chat`, and `Download`.
- File lifecycle: downloads are stored on disk under `DOWNLOADS_DIR`; soft-delete and sync flows live in `app/services/downloads/*` and `lib/tasks/downloads*.rake`.
- Background processing: Solid Queue is used for async jobs.

## Working Rules

- Keep user-facing text, comments, and commit messages in English.
- Stay consistent with existing Rails patterns; prefer small service objects over growing jobs/controllers.
- Preserve current Telegram behavior unless the task explicitly changes bot UX.
- Prefer localized error and status messages via `config/locales/*.yml`.
- Do not assume the downloader can safely hit the network in tests; stub process and filesystem edges.
- Be careful with file deletion and path moves. The project relies on local disk state matching DB state.

## High-Value Files

- `README.md`: product and setup overview.
- `app/jobs/download_job.rb`: main download orchestration.
- `app/jobs/telegram_update_job.rb`: Telegram event routing.
- `app/services/ytdlp_downloader.rb`: `yt-dlp` command construction and execution.
- `app/services/downloads/limits_checker.rb`: disk and per-user quota enforcement.
- `app/services/downloads/notifier.rb`: user/admin messaging policy.
- `app/services/telegram/handlers/*.rb`: message-type-specific bot behavior.
- `lib/tasks/downloads_sync.rake`: disk-to-DB reconciliation.

## Commands

- Setup: `bin/setup`
- Run app: `bin/rails s -b 0.0.0.0 -p 3000`
- Run jobs: `bin/jobs start`
- Run test suite: `bundle exec rspec`
- Run focused specs: `bundle exec rspec spec/path/to/file_spec.rb`
- CI checks: `bin/ci`
- Security scan: `bin/brakeman`
- Lint: `bin/rubocop`

## Testing Expectations

- Add or update specs for every non-trivial behavior change.
- Keep specs close to the logic they verify:
  `spec/models/*` for validations, associations, enums, scopes, and model defaults,
  `spec/jobs/*` for orchestration,
  `spec/services/downloads/*` for quota/notifier/service behavior,
  `spec/services/telegram/handlers/*` for message handling,
  `spec/requests/*` for webhook integration.
- Prefer `let`, explicit contexts, and narrow stubs over broad setup.
- When changing env-driven logic, isolate ENV access or stub boundaries instead of mutating unrelated framework state.

## Common Pitfalls

- `Download` uses soft delete (`paranoia`) and also defines a default scope; be explicit when querying deleted records.
- `Chat#private?` changes storage layout: private chats use `user_<id>`, other chats use `chat_<id>`.
- `Downloads::Notifier` intentionally shows detailed errors to admins and quota-related errors to regular users.
- `YtdlpDownloader` depends on external binaries and temp directories; keep failure paths observable and testable.
- `downloads:sync:by_user` only tracks visible `.mp4` and `.mp3` files and soft-deletes missing DB records.

## Agent Selection

- Use `.codex/agents/telegram-flow.toml` for webhook, parser, handler, and bot command work.
- Use `.codex/agents/download-pipeline.toml` for `DownloadJob`, `yt-dlp`, storage, quota, or notifier work.
- Use `.codex/agents/model-layer.toml` for `User`, `Chat`, `Download`, validations, scopes, enums, defaults, and model specs.
- Use `.codex/agents/data-ops.toml` for migrations, rake tasks, sync, soft-delete/restore, and operational safety changes.
- Use `.codex/agents/test-guardian.toml` for spec design, regression coverage, and CI stabilization.
- Use `.codex/agents/reviewer.toml` for code review, regression hunting, and testing-gap analysis.
