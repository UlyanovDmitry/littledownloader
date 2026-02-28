# frozen_string_literal: true

module Telegram
  module Handlers
    class VideoHandler < DocumentHandler
      private
      def file_object
        @file_object ||= message&.video
      end
    end
  end
end
