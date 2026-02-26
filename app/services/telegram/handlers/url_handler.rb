# frozen_string_literal: true

module Telegram
  module Handlers
    class UrlHandler < BaseHandler
      def call
        url = extract_url
        audio_only = msg.text.include?('audio-only')

        download = Download.create!(
          user: user,
          chat_id: chat_id,
          url: url,
          status: :queued,
          audio_only: audio_only
        )

        DownloadJob.perform_later(download.id)
        TelegramClient.send_message(
          chat_id: chat_id,
          text: I18n.t('telegram.handlers.download.queued', id: download.id)
        )
      end

      private

      def extract_url
        # We assume the URL is present because this handler was chosen
        # But just in case, find it among the entities or with a regex
        msg.text.match(%r{https?://\S+})[0]
      end
    end
  end
end
