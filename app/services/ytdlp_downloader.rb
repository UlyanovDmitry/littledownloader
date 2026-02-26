# frozen_string_literal: true

require 'open3'

class YtdlpDownloader
  class DownloadError < StandardError; end

  DEFAULT_FORMAT_SELECTOR = 'bestvideo[height<=2160]+bestaudio/best'
  DEFAULT_MERGE_FORMAT = 'mp4'
  DEFAULT_AUDIO_FORMAT = 'mp3'

  def initialize(url, download_dir: ENV.fetch('DOWNLOAD_DIR', 'tmp/downloads'), audio_only: false)
    @url = url
    @download_dir = download_dir
    @audio_only = audio_only
  end

  def download
    ensure_bin!('yt-dlp')
    ensure_bin!('ffmpeg')

    FileUtils.mkdir_p(@download_dir)

    cmd = build_command
    run!(cmd)
  end

  private

  def ensure_bin!(name)
    return if system("which #{name} >/dev/null 2>&1")

    raise DownloadError, "Required binary `#{name}` is missing. Install via Homebrew: brew install #{name}"
  end

  def build_command
    # Шаблон имени файла: скачиваем в указанную директорию
    out_template = File.join(@download_dir, '%(title)s.%(ext)s')

    cmd = %w[yt-dlp --no-color --newline]
    cmd += ['-o', out_template]
    cmd += ['--ignore-errors']

    if @audio_only
      cmd += ['-x', '--audio-format', DEFAULT_AUDIO_FORMAT]
      cmd += ['--embed-metadata', '--embed-thumbnail']
    else
      cmd += ['-f', DEFAULT_FORMAT_SELECTOR]
      cmd += ['--merge-output-format', DEFAULT_MERGE_FORMAT]
      cmd += ['--embed-metadata', '--embed-thumbnail']
    end

    cmd << @url
    cmd
  end

  def run!(cmd_ary)
    status = nil
    Open3.popen2e(*cmd_ary) do |_stdin, out, wait|
      # В реальном приложении можно логировать вывод или отправлять прогресс пользователю
      out.each { |line| Rails.logger.info("[yt-dlp] #{line.strip}") if defined?(Rails) }
      status = wait.value
    end

    unless status.success?
      raise DownloadError, "Command failed with exit status #{status.exitstatus}"
    end

    true
  end
end
