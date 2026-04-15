module Telegram
  module Handlers
    class MentionHandler < TextHandler
      private

      def perform
        return UrlHandler.call(chat, user, tg_update) if extract_url.present?

        super
      end

      def message_for_bot?
        mention_bot?
      end
    end
  end
end
