# frozen_string_literal: true

module Telegram
  module Handlers
    class UrlHandler < BaseHandler
      def call
        perform
      rescue TelegramClient::ResponseError => e
        TelegramClient.send_message(chat_id: chat_id, text: I18n.t('telegram.handlers.download.errors.telegram_error', error: e.message))
        raise e
      end

      private

      def perform
        return send_no_url_message if extract_url.blank?

        audio_only = message_text.to_s.include?('audio-only')

        download = Download.create!(
          user: user,
          chat: chat,
          url: extract_url,
          status: :queued,
          audio_only: audio_only
        )

        DownloadJob.perform_later(download.id)
        TelegramClient.send_message(
          chat_id: chat_id,
          text: I18n.t('telegram.handlers.download.queued', id: download.id)
        )
      end

      def send_no_url_message
        TelegramClient.send_message(chat_id: chat_id, text: I18n.t('telegram.handlers.download.errors.no_url'))
      end
    end
  end
end
