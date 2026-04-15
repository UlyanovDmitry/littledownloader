module Telegram
  module Handlers
    class MentionHandler < TextHandler
      def call
        return unless message_for_bot?
        return super unless download_allowed?

        UrlHandler.call(chat, user, tg_update)
      end

      private
      def message_for_bot?
        mention_bot?
      end
    end
  end
end
