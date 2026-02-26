class DownloadJob < ApplicationJob
  queue_as :default

  def perform(download_id)
    download = Download.find(download_id)
    download.update!(status: :running)

    base_dir = ENV.fetch('DOWNLOAD_DIR', 'tmp/downloads')
    user_dir = "user_#{download.user_id}"
    download_dir = File.join(base_dir, user_dir)

    downloader = YtdlpDownloader.new(
      download.url,
      download_dir: download_dir,
      audio_only: download.audio_only
    )

    result = downloader.download

    update_params = { status: :done }
    if result.is_a?(String)
      update_params[:output_path] = result
      update_params[:file_size] = File.size(result) if File.exist?(result)
      filename = File.basename(result)
    else
      filename = 'unknown'
    end

    download.update!(update_params)

    TelegramClient.send_message(
      chat_id: download.chat_id,
      text: I18n.t('telegram.handlers.download.success', id: download.id, filename: filename)
    )

    notify_admins_on_success(download, filename)
  rescue StandardError => e
    download ||= Download.find_by(id: download_id)
    if download
      Rails.logger.error("[DownloadJob] Error downloading #{download.url}: #{e.message}")
      download.update!(status: :failed, error: e.message)

      TelegramClient.send_message(
        chat_id: download.chat_id,
        text: I18n.t('telegram.handlers.download.failed', id: download.id, error: e.message)
      )

      notify_admins_on_failure(download, e.message)
    else
      Rails.logger.error("[DownloadJob] Error with unknown download_id #{download_id}: #{e.message}")
    end
    raise e
  end

  private

  def notify_admins_on_success(download, filename)
    notify_admins(
      download,
      I18n.t('telegram.handlers.download.admin_notification', id: download.id, filename: filename, username: download.user.username)
    )
  end

  def notify_admins_on_failure(download, error)
    notify_admins(
      download,
      I18n.t('telegram.handlers.download.admin_failed_notification', id: download.id, error: error, username: download.user.username)
    )
  end

  def notify_admins(download, text)
    User.where(role: 'admin').where.not(id: download.user_id).find_each do |admin|
      TelegramClient.send_message(chat_id: admin.telegram_user_id, text: text)
    end
  end
end
