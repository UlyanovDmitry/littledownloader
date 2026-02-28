class DownloadJob < ApplicationJob
  queue_as :default

  def perform(download_id)
    download = Download.find(download_id)
    download.update!(status: :running)

    result = process_download(download)
    finalize_download!(download, result)
  rescue StandardError => e
    handle_failure(download_id, e)
    raise e
  end

  private

  def process_download(download)
    base_dir = prepare_base_dir
    Downloads::LimitsChecker.new(download: download, base_dir: base_dir).call

    build_downloader(download, base_dir).download.tap do |result|
      Rails.logger.info("[DownloadJob] Downloader result: #{result.inspect}")
    end
  end

  def prepare_base_dir
    ENV.fetch('DOWNLOADS_DIR', 'tmp/downloads').tap do |base_dir|
      FileUtils.mkdir_p(base_dir)
    end
  end

  def build_downloader(download, base_dir)
    download_last_dir = download.chat.private? ? "user_#{download.user_id}" : "chat_#{download.chat_id}"

    YtdlpDownloader.new(
      download.url,
      download_dir: File.join(base_dir, download_last_dir),
      audio_only: download.audio_only
    )
  end

  def finalize_download!(download, result)
    filename, update_params = build_result_attributes(result)
    download.update!(update_params)

    Downloads::Notifier.new(download).notify_success(filename)
  end

  def build_result_attributes(result)
    return ['unknown', { status: :done }] unless result.is_a?(String)

    update_params = {
      status: :done,
      output_path: result
    }

    exists = File.exist?(result)
    Rails.logger.debug("[DownloadJob] File exists at #{result}: #{exists}")

    if exists
      update_params[:file_size] = File.size(result)
      Rails.logger.debug("[DownloadJob] File size: #{update_params[:file_size]}")
    end

    [File.basename(result), update_params]
  end

  def handle_failure(download_id, error)
    download = Download.find_by(id: download_id)
    unless download
      Rails.logger.error("[DownloadJob] Error with unknown download_id #{download_id}: #{error.message}")
      return
    end

    Rails.logger.error("[DownloadJob] Error downloading #{download.url}: #{error.message}")
    download.update!(status: :failed, error: error.message)

    Downloads::Notifier.new(download).notify_failure(error)
  end
end
