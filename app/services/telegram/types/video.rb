# frozen_string_literal: true

module Telegram
  module Types
    class Video < BaseFile
      attr_accessor :duration, :width, :height
    end
  end
end
