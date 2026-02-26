module Downloads
  class RestoreService
    def self.by_uuid!(uuid)
      download_scope = Download.with_deleted.where(id: uuid).where.not(deleted_at: nil)
      new(download_scope).call
    end

    def self.by_user!(user_id)
      download_scope = Download.only_deleted.where(user_id: user_id)
      new(download_scope).call
    end

    def self.all!
      download_scope = Download.only_deleted
      new(download_scope).call
    end

    def initialize(scope)
      @scope = scope
    end

    def call
      affected = 0

      scope.find_each do |download|
        restore!(download)
        affected += 1
      end

      affected
    end

    private

    attr_reader :scope

    def restore!(download)
      Download.transaction do
        restored_path = Downloads::PathManager.restore_from_trash(download.output_path)
        download.update!(deleted_at: nil)
        download.update!(output_path: restored_path) if restored_path != download.output_path
      end
    end
  end
end
