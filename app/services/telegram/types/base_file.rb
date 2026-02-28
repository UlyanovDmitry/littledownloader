# frozen_string_literal: true

module Telegram
  module Types
    class BaseFile < BaseType
      attr_accessor :file_id, :file_unique_id, :file_size, :file_name, :mime_type, :thumbnail, :thumb
    end
  end
end
