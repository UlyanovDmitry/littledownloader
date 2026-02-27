# LittleDownloader

LittleDownloader is a self-hosted Telegram bot for downloading media from YouTube and similar platforms.

The bot accepts links via Telegram, queues download tasks, stores files locally on disk, and notifies users when downloads are completed.  
No files are uploaded back to Telegram — the bot only manages downloads and storage.

## Features

- Telegram bot
- Background jobs via Solid Queue
- Local file storage
- Per-user storage quotas
- Admin notifications
- PostgreSQL for persistence
- Rails 8 app, simple and fast

## Architecture

- **web** — Telegram webhook handler and business logic (Rails)
- **jobs** — background downloads (yt-dlp + ffmpeg)
- **PostgreSQL** — users, downloads, quotas, queues

## Requirements

- Ruby 4.0+
- PostgreSQL
- `yt-dlp` installed on the system
- `ffmpeg` (recommended)

## Configuration

The application is configured via environment variables:

```env
TELEGRAM_WEBHOOK_HEADER_TOKEN=header_token_456
TELEGRAM_BOT_TOKEN=telegram_bot_token
TELEGRAM_WEBHOOK_SECRET=your_webhook_secret
DOWNLOADS_DIR=/absolute/path/to/downloads
```

## Bot Commands

- `/start` — запуск
- `/help` — помощь
- `/info` — информация о профиле

Parameters:
- `audio-only` — скачать только аудио
- `info` — показать информацию о загрузке

## Development

Start the app and Postgres with Docker Compose:

```bash
docker compose up --build
```

Start the app locally (requires a running Postgres):

```bash
bundle install
bin/rails s -b 0.0.0.0 -p 3000
```

Start background jobs:

```bash
bin/jobs start
```

## Docker

Create a `.env` file (example):

```env
TELEGRAM_WEBHOOK_HEADER_TOKEN=header_token_456
TELEGRAM_BOT_TOKEN=telegram_bot_token
TELEGRAM_WEBHOOK_SECRET=your_webhook_secret
DOWNLOADS_DIR=/downloads
DOWNLOADS_HOST_DIR=/absolute/path/to/downloads
```

Start everything:

```bash
docker compose up --build
```

## Notes
- This project is designed for self-hosting.
- Storage management and quotas are enforced on the server side.
- The bot does not redistribute copyrighted content — usage is the responsibility of the operator.
