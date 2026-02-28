# frozen_string_literal: true

module Telegram
  module Handlers
    class BaseHandler
      attr_reader :chat_id, :msg, :user, :tg_update
      private :chat_id, :msg, :tg_update

      def self.call(chat_id, user, tg_update) = new(chat_id, user, tg_update).call

      def initialize(chat_id, user, tg_update)
        @chat_id = chat_id
        @user = user
        @tg_update = tg_update
      end

      delegate :message, to: :tg_update
      delegate :text, to: :message, prefix: :message

      def call
        raise NotImplementedError
      end
    end
  end
end
