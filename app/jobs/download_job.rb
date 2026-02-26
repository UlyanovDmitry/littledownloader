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
    update_params[:output_path] = result if result.is_a?(String)

    download.update!(update_params)
  rescue StandardError => e
    Rails.logger.error("[DownloadJob] Error downloading #{download.url}: #{e.message}")
    download.update!(status: :failed, error: e.message)
    raise e
  end
end
