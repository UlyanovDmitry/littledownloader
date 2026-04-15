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
        return unless message_for_bot?

        perform
      end

      private

      def perform
        raise NotImplementedError
      end

      def chat_id
        chat.telegram_chat_id
      end

      def message_text
        @message_text ||= message.text&.delete_prefix(TELEGRAM_BOT_NAME)
      end

      def message_for_bot?
        chat.private? || mention_bot?
      end

      def mention_bot?
        full_message_text.start_with?(TELEGRAM_BOT_NAME) || full_message_text.end_with?(TELEGRAM_BOT_NAME)
      end

      def full_message_text
        @full_message_text ||= message.text.to_s
      end
    end
  end
end
