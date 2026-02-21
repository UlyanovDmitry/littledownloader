# frozen_string_literal: true

module Telegram
  module Handlers
    class BaseHandler
      attr_reader :chat_id, :msg, :user
      private :chat_id, :msg

      def self.call(chat_id, msg, user) = new(chat_id, msg, user).call

      def initialize(chat_id, msg, user)
        @chat_id = chat_id
        @msg = msg
        @user = user
      end

      def call
        raise NotImplementedError
      end
    end
  end
end
