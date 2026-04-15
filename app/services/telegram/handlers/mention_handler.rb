module Telegram
  module Handlers
    class MentionHandler < UrlHandler
      def call
        return unless message_for_bot?
        return TextHandler.call(chat, user, tg_update) if extract_url.blank?

        super
      end

      private
      def message_for_bot?
        mention_bot?
      end
    end
  end
end
