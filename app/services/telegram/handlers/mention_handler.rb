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
    end
  end
end
