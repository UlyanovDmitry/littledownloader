# frozen_string_literal: true

module Telegram
  module Handlers
    class BaseHandler
      attr_reader :chat, :msg, :user, :tg_update
      private :chat, :msg, :tg_update

      def self.call(chat, user, tg_update) = new(chat, user, tg_update).call

      def initialize(chat, user, tg_update)
        @chat = chat
        @user = user
        @tg_update = tg_update
      end

      delegate :message, to: :tg_update
      delegate :text, to: :message, prefix: :message

      def call
        raise NotImplementedError
      end

      private

      def chat_id
        chat.telegram_chat_id
      end
    end
  end
end
