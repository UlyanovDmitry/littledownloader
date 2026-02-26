module Downloads
  class SoftDeleteService
    def self.by_uuid!(uuid)
      downloads_scope = Download.where(id: uuid)
      new(downloads_scope).call
    end

    def self.by_user!(user_id)
      downloads_scope = Download.where(user_id: user_id)
      new(downloads_scope).call
    end

    def self.all!
      downloads_scope = Download.all
      new(downloads_scope).call
    end

    def initialize(scope)
      @scope = scope
    end

    def call
      affected = 0

      record_count = scope.count
      # progress_bar = ProgressBar.create(total: record_count, format: '%a %e %P% Processed: %c from %C')
      progress_bar = ProgressBar.create(total: record_count) if Rails.env.development?

      scope.find_each do |download|
        soft_delete!(download)
        progress_bar.increment if Rails.env.development?
        affected += 1
      end

      affected
    end

    private

    attr_reader :scope

    def soft_delete!(download)
      Download.transaction do
        trashed_path = Downloads::PathManager.move_to_trash(download.output_path)
        download.update!(output_path: trashed_path) if trashed_path != download.output_path
        download.update!(deleted_at: Time.current) if download.deleted_at.nil?
      end
    end
  end
end
