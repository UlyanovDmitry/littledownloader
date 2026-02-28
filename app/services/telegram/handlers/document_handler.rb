# frozen_string_literal: true

module Telegram
  module Handlers
    class DocumentHandler < UrlHandler
      ALLOWED_MAX_FILE_SIZE =  ENV.fetch('MAX_DOWNLOAD_FILE_GB', 20).to_i.megabytes

      private

      def extract_url
        file_id = file_object&.file_id
        return unless file_id

        @extract_url ||= TelegramClient.get_file_path(file_id)
      end

      def file_object
        @file_object ||= message&.document
      end
      def download_allowed?
        if file_object.file_size > ALLOWED_MAX_FILE_SIZE
          TelegramClient.send_message(
            chat_id:,
            text: I18n.t(
              'telegram.handlers.download.errors.file_too_big',
              limit_size: ActiveSupport::NumberHelper.number_to_human_size(ALLOWED_MAX_FILE_SIZE),
              file_size: ActiveSupport::NumberHelper.number_to_human_size(file_object.file_size)
            )
          )
          return false
        end

        super
      end
    end
  end
end
