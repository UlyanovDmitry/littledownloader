module Telegram
  module Handlers
    class MentionHandler < TextHandler
      def call
        super unless download_allowed?

        UrlHandler.call(chat, user, tg_update)
      end

      private
      def message_for_bot?
        true
      end

      def message_text
        @message_text ||= message.text.delete_prefix(TELEGRAM_BOT_NAME)
      end
    end
  end
end
