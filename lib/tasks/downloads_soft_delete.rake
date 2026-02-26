namespace :downloads do
  namespace :soft_delete do
    # rake "downloads:soft_delete:one[783fc074-4fea-46e4-b8ba-410da9fe9c25]"
    desc 'Soft delete one download by UUID: rake downloads:soft_delete:one[UUID]'
    task :one, [:uuid] => :environment do |_task, args|
      uuid = args[:uuid]
      raise ArgumentError, 'uuid is required' if uuid.blank?

      deleted_count = Downloads::SoftDeleteService.by_uuid!(uuid)
      puts "Soft-deleted downloads: #{deleted_count}"
    end

    # rake "downloads:soft_delete:by_user[1]"
    desc 'Soft delete all downloads by user id: rake downloads:soft_delete:by_user[USER_ID]'
    task :by_user, [:user_id] => :environment do |_task, args|
      user_id = args[:user_id]
      raise ArgumentError, 'user_id is required' if user_id.blank?

      deleted_count = Downloads::SoftDeleteService.by_user!(user_id)
      puts "Soft-deleted downloads: #{deleted_count}"
    end

    desc 'Soft delete all downloads for all users: rake downloads:soft_delete:all'
    task all: :environment do
      deleted_count = Downloads::SoftDeleteService.all!
      puts "Soft-deleted downloads: #{deleted_count}"
    end
  end

  namespace :restore do
    # rake "downloads:restore:one[783fc074-4fea-46e4-b8ba-410da9fe9c25]"
    desc 'Restore one download by UUID: rake downloads:restore:one[UUID]'
    task :one, [:uuid] => :environment do |_task, args|
      uuid = args[:uuid]
      raise ArgumentError, 'uuid is required' if uuid.blank?

      restored_count = Downloads::RestoreService.by_uuid!(uuid)
      puts "Restored downloads: #{restored_count}"
    end

    # rake "downloads:restore:by_user[1]"
    desc 'Restore all downloads by user id: rake downloads:restore:by_user[USER_ID]'
    task :by_user, [:user_id] => :environment do |_task, args|
      user_id = args[:user_id]
      raise ArgumentError, 'user_id is required' if user_id.blank?

      restored_count = Downloads::RestoreService.by_user!(user_id)
      puts "Restored downloads: #{restored_count}"
    end

    desc 'Restore all soft-deleted downloads for all users: rake downloads:restore:all'
    task all: :environment do
      restored_count = Downloads::RestoreService.all!
      puts "Restored downloads: #{restored_count}"
    end
  end
end
