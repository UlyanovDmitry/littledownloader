# frozen_string_literal: true

require 'open3'
require 'securerandom'
require 'tmpdir'

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

    # Создаем временную директорию для процесса скачивания
    tmp_dir = File.join(Dir.tmpdir, "ytdlp_#{SecureRandom.hex(8)}")
    FileUtils.mkdir_p(tmp_dir)

    begin
      cmd = build_command(tmp_dir)
      result_path = run!(cmd)

      if result_path && File.exist?(result_path)
        final_path = File.join(@download_dir, File.basename(result_path))
        FileUtils.mv(result_path, final_path)
        final_path
      else
        result_path
      end
    ensure
      FileUtils.rm_rf(tmp_dir)
    end
  end

  private

  def ensure_bin!(name)
    return if system("which #{name} >/dev/null 2>&1")

    raise DownloadError, "Required binary `#{name}` is missing. Install via Homebrew: brew install #{name}"
  end

  def build_command(target_dir = @download_dir)
    out_template = File.join(target_dir, '%(title)s.%(ext)s')

    cmd = %w[yt-dlp --no-color --newline]
    cmd += ['--print', 'after_move:filepath']
    cmd += ['--extractor-args', 'youtube:player_client=web']
    cmd += ['-o', out_template]
    cmd += ['--ignore-errors', '--no-mtime']

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
    last_lines = []
    output_path = nil

    Open3.popen2e(*cmd_ary) do |_stdin, out, wait|
      out.each do |line|
        stripped_line = line.strip
        Rails.logger.debug("[yt-dlp] #{stripped_line}") if defined?(Rails)

        # Если строка выглядит как абсолютный путь и содержит расширение (из-за --print after_move:filepath)
        if stripped_line.start_with?('/') && File.extname(stripped_line).present?
          output_path = stripped_line
        end

        last_lines << stripped_line
        last_lines.shift if last_lines.size > 10
      end
      status = wait.value
    end

    unless status.success?
      error_details = last_lines.join("\n")
      raise DownloadError, "Command failed with exit status #{status.exitstatus}\nDetails:\n#{error_details}"
    end

    output_path
  end
end
