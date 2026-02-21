module Telegram
  module Handlers
    class TextHandler < BaseHandler
      def call
        return if msg.text.blank?

        TelegramClient.send_message(chat_id:, text: I18n.t('telegram.handlers.text_handler.message'))
      end
    end
  end
end
