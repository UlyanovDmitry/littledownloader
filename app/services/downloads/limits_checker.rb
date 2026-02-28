require 'open3'

module Downloads
  class LimitsChecker
    DOWNLOADS_MIN_FREE_SIZE = ENV.fetch('DOWNLOADS_MIN_FREE_GB', 50).to_i.gigabytes
    MIN_HEADROOM_SIZE = ENV.fetch('DOWNLOADS_HEADROOM_GB', 2).to_i.gigabytes

    class LimitExceededError < StandardError
      attr_reader :used_human, :min_human

      def initialize(used_human, limit_human)
        @used_human = used_human
        @min_human = limit_human

        super I18n.t(
          'telegram.handlers.download.errors.limit_exceeded',
          used: used_human,
          limit: limit_human
        )
      end
    end

    class DiskSpaceError < StandardError
      attr_reader :free_human, :min_human

      def initialize(free_human, min_human)
        @free_human = free_human
        @min_human = min_human

        super I18n.t(
          'telegram.handlers.download.errors.disk_space',
          free: free_human,
          required: min_human
        )
      end
    end

    def initialize(download:, base_dir:)
      @download = download
      @base_dir = base_dir
    end

    def call
      ensure_disk_space!
      ensure_user_quota!
    end

    private

    attr_reader :download, :base_dir

    def ensure_disk_space!
      return if DOWNLOADS_MIN_FREE_SIZE <= 0

      free_bytes = disk_free_bytes
      return if free_bytes.nil?

      return if free_bytes >= DOWNLOADS_MIN_FREE_SIZE

      free_human = ActiveSupport::NumberHelper.number_to_human_size(free_bytes)
      min_human = ActiveSupport::NumberHelper.number_to_human_size(DOWNLOADS_MIN_FREE_SIZE)
      raise DiskSpaceError.new(free_human, min_human)
    end

    def disk_free_bytes
      output, status = Open3.capture2('df', '-kP', base_dir)
      return nil unless status.success?

      line = output.split("\n").last
      fields = line.to_s.split(/\s+/)
      return nil if fields.size < 4

      fields[3].to_i * 1024
    rescue StandardError => e
      Rails.logger.error("[DownloadJob] Failed to read disk free space: #{e.message}")
      nil
    end

    def ensure_user_quota!
      limit_bytes = download.user.storage_limit_bytes
      return if limit_bytes.nil?

      used_bytes = download.user.downloads.where(status: :done).sum(:file_size)
      return if (limit_bytes - used_bytes) >= MIN_HEADROOM_SIZE

      used_human = ActiveSupport::NumberHelper.number_to_human_size(used_bytes)
      limit_human = ActiveSupport::NumberHelper.number_to_human_size(limit_bytes)
      raise LimitExceededError.new(used_human, limit_human)
    end
  end
end
