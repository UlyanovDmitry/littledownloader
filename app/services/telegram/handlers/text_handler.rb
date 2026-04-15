module Telegram
  module Handlers
    class TextHandler < BaseHandler
      def call
        return unless message_for_bot?

        TelegramClient.send_message(chat_id: chat_id, text: I18n.t('telegram.handlers.text_handler.message'))
      end

      private

      def message_for_bot?
        chat.private? || mention_bot?
      end

      def mention_bot?
        message.text.to_s.start_with?(TELEGRAM_BOT_NAME)
      end
    end
  end
end
