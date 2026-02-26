module Downloads
  class SoftDeleteService
    def self.by_uuid!(uuid)
      new(Download.where(id: uuid)).call
    end

    def self.by_user!(user_id)
      new(Download.where(user_id: user_id)).call
    end

    def self.all!
      new(Download.all).call
    end

    def initialize(scope)
      @scope = scope
    end

    def call
      affected = 0

      scope.find_each do |download|
        soft_delete!(download)
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
