# frozen_string_literal: true

module Telegram
  module Handlers
    class BotCommandHandler < BaseHandler
      def call
        case command_name
        when 'start'
          TelegramClient.send_message(chat_id:, text: I18n.t('telegram.handlers.start_command.message'))
        when 'whoami'
          TelegramClient.send_message(
            chat_id:,
            text: I18n.t(
              'telegram.handlers.whoami_command.message',
              telegram_id: user.telegram_user_id,
              username: user.username
            )
          )
        else
          TelegramClient.send_message(chat_id:, text: I18n.t('telegram.handlers.errors.unknown_command'))
        end
      end

      private

      def command_name
        msg.text.delete_prefix('/').downcase
      end
    end
  end
end
