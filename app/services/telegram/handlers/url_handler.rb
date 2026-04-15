# frozen_string_literal: true

module Telegram
  module Handlers
    class UrlHandler < BaseHandler
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
      rescue TelegramClient::ResponseError => e
        TelegramClient.send_message(chat_id: chat_id, text: I18n.t('telegram.handlers.download.errors.telegram_error', error: e.message))
        raise e
      end
      def send_no_url_message
        TelegramClient.send_message(chat_id: chat_id, text: I18n.t('telegram.handlers.download.errors.no_url'))
      end

      def extract_url
        # We assume the URL is present because this handler was chosen
        # But just in case, find it among the entities or with a regex
        @extract_url ||= begin
          match = message_text.match(%r{https?://\S+})
          match ? match[0] : nil
        end
      end

      def message_for_bot?
        extract_url.present?
      end
    end
  end
end
