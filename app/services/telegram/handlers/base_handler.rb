# frozen_string_literal: true

module Telegram
  module Handlers
    class BaseHandler
      TELEGRAM_BOT_NAME = ENV.fetch('TELEGRAM_BOT_NAME', '@default_bot_name')

      attr_reader :chat, :msg, :user, :tg_update
      private :chat, :msg, :tg_update

      def self.call(chat, user, tg_update) = new(chat, user, tg_update).call

      def initialize(chat, user, tg_update)
        @chat = chat
        @user = user
        @tg_update = tg_update
      end

      delegate :message, to: :tg_update

      def call
        raise NotImplementedError
      end

      private

      def chat_id
        chat.telegram_chat_id
      end

      def message_text
        @message_text ||= message.text&.delete_prefix(TELEGRAM_BOT_NAME)
      end

      def extract_url
        # We assume the URL is present because this handler was chosen
        # But just in case, find it among the entities or with a regex
        @extract_url ||= begin
          match = message_text.match(%r{https?://\S+})
          match ? match[0] : nil
        end
      end

      def download_allowed?
        if extract_url.blank?
          TelegramClient.send_message(chat_id: chat_id, text: I18n.t('telegram.handlers.download.errors.no_url'))
          return false
        end

        true
      end
    end
  end
end
