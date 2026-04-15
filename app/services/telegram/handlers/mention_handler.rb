module Telegram
  module Handlers
    class MentionHandler < UrlHandler

      private

      def perform
        return TextHandler.call(chat, user, tg_update) if extract_url.blank?

        super
      end

      def message_for_bot?
        mention_bot?
      end
    end
  end
end
