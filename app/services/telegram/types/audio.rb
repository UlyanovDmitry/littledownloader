# frozen_string_literal: true

module Telegram
  module Types
    class Audio < BaseFile
      attr_accessor :duration, :performer, :title, :file_id
    end
  end
end
