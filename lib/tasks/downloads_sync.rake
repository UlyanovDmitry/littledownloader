require 'find'

namespace :downloads do
  namespace :sync do
    # rake "downloads:sync:by_user[1]"
    desc 'Sync downloads for user id: rake downloads:sync:by_user[USER_ID]'
    task :by_user, [:user_id] => :environment do |_task, args|
      user_id = args[:user_id]
      raise ArgumentError, 'user_id is required' if user_id.blank?

      user = User.find_by(id: user_id)
      unless user
        puts "User not found: #{user_id}"
        next
      end

      base_dir = ENV.fetch('DOWNLOADS_DIR', 'tmp/downloads')
      user_dir = File.join(base_dir, "user_#{user.id}")
      unless Dir.exist?(user_dir)
        puts "Directory not found: #{user_dir}"
        next
      end

      chat_id = user.downloads.first.chat_id || user.telegram_user_id
      allowed_exts = %w[.mp4 .mp3].freeze

      created = 0
      updated = 0
      unchanged = 0
      deleted = 0

      seen_paths = []

      Find.find(user_dir) do |path|
        if File.directory?(path)
          if File.basename(path) == Downloads::PathManager::TRASH_DIR_NAME
            Find.prune
          else
            next
          end
        end

        next unless File.file?(path)
        next if File.basename(path).start_with?('.')

        ext = File.extname(path).downcase
        next unless allowed_exts.include?(ext)

        file_size = File.size(path)
        seen_paths << path
        download = Download.find_by(output_path: path)

        if download
          if download.file_size != file_size
            download.update!(file_size: file_size)
            updated += 1
          else
            unchanged += 1
          end
        else
          Download.create!(
            user: user,
            chat_id: chat_id,
            url: "file://#{path}",
            status: :done,
            audio_only: ext == '.mp3',
            output_path: path,
            file_size: file_size
          )
          created += 1
        end
      end

      scope = user.downloads.where.not(output_path: [nil, ''])
      scope.find_each do |download|
        path = download.output_path
        next unless path.start_with?(user_dir)
        next if seen_paths.include?(path)

        download.delete
        deleted += 1
      end

      puts "Sync complete for user #{user.id}. created=#{created} updated=#{updated} unchanged=#{unchanged} deleted=#{deleted}"
    end
  end
end
