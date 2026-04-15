module Telegram
  module Handlers
    class TextHandler < BaseHandler
      def call
        return unless message_for_bot?

        TelegramClient.send_message(chat_id: chat_id, text: I18n.t('telegram.handlers.text_handler.message'))
      end

      private

      def message_for_bot?
        if message_starts_with_mention?
          mention_bot?
        else
          chat.private?
        end
      end

      def message_starts_with_mention?
        message.entities.any? { |entity| entity.type == 'mention' && entity.offset == 0 }
      end

      def mention_bot?
        return false unless message.text.to_s.start_with?(TELEGRAM_BOT_NAME)

        message.entities.any? { |entity| entity.type == 'mention' && message.text[entity.offset, entity.length] == TELEGRAM_BOT_NAME }
      end
    end
  end
end
