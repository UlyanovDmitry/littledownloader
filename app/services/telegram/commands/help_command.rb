# frozen_string_literal: true

module Telegram
  module Commands
    class HelpCommand < BaseCommand
      private

      def handle_command
        TelegramClient.send_message(
          chat_id: chat_id, text: 'Still under development, but you can explore the interface if you want.',
        )
      end
    end
  end
end
