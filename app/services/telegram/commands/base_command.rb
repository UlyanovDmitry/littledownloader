# frozen_string_literal: true

module Telegram
  module Commands
    class BaseCommand
      attr_reader :msg, :chat_id, :from
      private :msg, :chat_id, :from
      alias :tg_user :from
      def self.call(msg) = new(msg).call

      def initialize(msg)
        @msg = msg
        @chat_id = msg.dig('chat', 'id')
        @from = msg['from'] || {}
      end

      def call
        return if chat_id.blank?

        handle_command
      end

      private

      def handle_command
        raise NotImplementedError
      end
    end
  end
end
