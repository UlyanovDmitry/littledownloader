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
      end

      private

      def extract_url
        # Мы предполагаем что URL точно есть, так как этот хендлер был выбран
        # Но на всякий случай найдем его среди сущностей или просто регуляркой
        msg.text.match(%r{https?://\S+})[0]
      end
    end
  end
end
