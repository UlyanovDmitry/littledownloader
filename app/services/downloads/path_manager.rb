require 'fileutils'
require 'pathname'
require 'securerandom'

module Downloads
  class PathManager
    TRASH_DIR_NAME = 'trash'.freeze

    class << self
      def move_to_trash(path)
        return path if path.blank?
        return path if in_trash?(path)

        destination = build_trash_destination(path)
        move_file(path, destination)
      end

      def restore_from_trash(path)
        return path if path.blank?
        return path unless in_trash?(path)

        destination = build_restore_destination(path)
        move_file(path, destination)
      end

      private

      def move_file(source, destination)
        return source unless File.exist?(source)

        FileUtils.mkdir_p(File.dirname(destination))
        FileUtils.mv(source, destination)
        destination
      end

      def in_trash?(path)
        parts = Pathname.new(path).each_filename.to_a
        parts.include?(TRASH_DIR_NAME)
      end

      def build_trash_destination(path)
        source = Pathname.new(path)
        source_dir = source.dirname
        trash_dir = source_dir.join(TRASH_DIR_NAME)
        ensure_unique_path(trash_dir.join(source.basename.to_s).to_s)
      end

      def build_restore_destination(path)
        source = Pathname.new(path)
        parts = source.each_filename.to_a
        trash_index = parts.rindex(TRASH_DIR_NAME)
        return path unless trash_index

        restored_parts = parts.dup
        restored_parts.delete_at(trash_index)
        destination = if path.start_with?(File::SEPARATOR)
                        File.join(File::SEPARATOR, *restored_parts)
        else
          File.join(*restored_parts)
        end
        ensure_unique_path(destination)
      end

      def ensure_unique_path(path)
        return path unless File.exist?(path)

        dir = File.dirname(path)
        ext = File.extname(path)
        base = File.basename(path, ext)

        loop do
          candidate = File.join(dir, "#{base}_#{SecureRandom.hex(4)}#{ext}")
          return candidate unless File.exist?(candidate)
        end
      end
    end
  end
end
