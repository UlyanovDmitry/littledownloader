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
        return false if message.entities.blank?

        message.entities.any? do |entity|
          next false unless entity.type == 'mention'

          slice_by_telegram_offsets(full_message_text, entity.offset, entity.length) == TELEGRAM_BOT_NAME
        end
      end

      def full_message_text
        @full_message_text ||= message.text.to_s
      end

      def extract_url
        @extract_url ||= message.entities.find { |entity| entity.type == 'url' }&.then do |url_entity|
          slice_by_telegram_offsets(full_message_text, url_entity.offset, url_entity.length)
        end || ''
      end

      def slice_by_telegram_offsets(text, offset, length)
        # Telegram counts offsets in UTF-16 code units.
        # Ruby String#slice counts in characters.
        # We convert to UTF-16, use byteslice (each code unit is 2 bytes), then convert back.
        text.encode('UTF-16LE').byteslice(offset * 2, length * 2).force_encoding('UTF-16LE').encode('UTF-8')
      end
    end
  end
end
