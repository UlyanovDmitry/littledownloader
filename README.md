# LittleDownloader

LittleDownloader is a self-hosted Telegram bot for downloading media from YouTube and similar platforms.

The bot accepts links via Telegram, queues download tasks, stores files locally on disk, and notifies users when downloads are completed.  
No files are uploaded back to Telegram — the bot only manages downloads and storage.

## Features

- Telegram bot with webhook support
- Async background jobs (Asynq + Redis)
- Local file storage
- Per-user and global storage quotas
- Retry last download command
- Admin notifications
- Basic rate limiting and authorization
- PostgreSQL for persistence
- Go-based, simple and fast

## Architecture

- **bot-api** — Telegram webhook handler and business logic
- **worker** — background downloader (yt-dlp + ffmpeg)
- **PostgreSQL** — users, downloads, quotas
- **Redis** — task queue (Asynq)

## Requirements

- Go 1.22+
- PostgreSQL
- Redis
- `yt-dlp` installed on the system
- `ffmpeg` (recommended)

## Configuration

The application is configured via environment variables:

```env
TELEGRAM_TOKEN=your_bot_token
WEBHOOK_HEADER_TOKEN=optional_secret
DATABASE_URL=postgres://user:pass@localhost:5432/dbname
REDIS_ADDR=localhost:6379
DOWNLOADS_DIR=/absolute/path/to/downloads
```

## Development

Run database migrations:

```bash
make migrate-up
```

Run database migrations with Docker Compose:

```bash
make dc-migrate-up
```

Run bot API:

```bash
go run ./cmd/bot-api
```

Run worker:
```bash
go run ./cmd/worker
```

Run tests:
```bash
go test ./...
```

## Docker

Create a `.env` file (example):

```env
TELEGRAM_TOKEN=your_bot_token
WEBHOOK_SECRET=your_webhook_secret
WEBHOOK_HEADER_TOKEN=optional_header_token
DOWNLOADS_DIR=/downloads
DOWNLOADS_HOST_DIR=/absolute/path/to/downloads
```

Start everything:

```bash
docker compose up --build
```

Notes:
- Migrations are not run automatically; apply them separately before starting the services.
- Run migrations in Docker: `docker compose --profile manual run --rm migrate` with `GOOSE_CMD=up|down|status|reset`.
- The bot API listens on port `8080` and exposes `/healthz`.
- Asynqmon UI is available at `http://localhost:8081`.
- Downloads are stored in the host directory set by `DOWNLOADS_HOST_DIR`.

## Notes
- This project is designed for self-hosting.
- Storage management and quotas are enforced on the server side.
- The bot does not redistribute copyrighted content — usage is the responsibility of the operator.
