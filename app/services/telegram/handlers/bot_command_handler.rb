# frozen_string_literal: true

module Telegram
  module Handlers
    class BotCommandHandler < BaseHandler
      def call
        case command_name
        when 'start'
          TelegramClient.send_message(chat_id:, text: I18n.t('telegram.handlers.start_command.message'))
        when 'info'
          TelegramClient.send_message(
            chat_id:,
            text: I18n.t(
              'telegram.handlers.info_command.message',
              telegram_id: user.telegram_user_id,
              username: user.username,
              disk_usage: disk_usage_text
            )
          )
        else
          TelegramClient.send_message(chat_id:, text: I18n.t('telegram.handlers.errors.unknown_command'))
        end
      end

      private

      def disk_usage_text
        total_bytes = user.downloads.where(status: :done).sum(:file_size)
        ActiveSupport::NumberHelper.number_to_human_size(total_bytes)
      end

      def command_name
        msg.text.delete_prefix('/').downcase
      end
    end
  end
end
