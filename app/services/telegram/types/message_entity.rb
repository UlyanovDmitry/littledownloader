# frozen_string_literal: true

module Telegram
  module Types
    class MessageEntity < BaseType
      attr_accessor :offset, :length, :type
    end
  end
end
