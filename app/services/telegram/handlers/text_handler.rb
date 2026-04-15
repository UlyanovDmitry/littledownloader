module Telegram
  module Handlers
    class TextHandler < BaseHandler
      def call
        return unless message_for_bot?

        TelegramClient.send_message(chat_id: chat_id, text: I18n.t('telegram.handlers.text_handler.message'))
      end
    end
  end
end
