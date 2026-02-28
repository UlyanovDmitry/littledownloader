# frozen_string_literal: true

module Telegram
  module Handlers
    class AudioHandler < DocumentHandler

      private

      def file_object
        @file_object ||= message&.audio
      end
    end
  end
end
