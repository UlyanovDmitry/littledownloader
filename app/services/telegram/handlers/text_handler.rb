module Telegram
  module Handlers
    class TextHandler < BaseHandler

      private

      def perform
        TelegramClient.send_message(chat_id: chat_id, text: I18n.t('telegram.handlers.text_handler.message'))
      end
    end
  end
end
