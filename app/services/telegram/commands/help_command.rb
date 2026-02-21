# frozen_string_literal: true

module Telegram
  module Commands
    class HelpCommand < BaseCommand
      private

      def handle_command
        TelegramClient.send_message(
          chat_id: chat_id, text: 'Пока еще в процессе разработки. Но ты можешь попробовать разобраться в интерфейсе',
        )
      end
    end
  end
end
