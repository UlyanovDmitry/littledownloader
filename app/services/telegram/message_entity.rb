# frozen_string_literal: true

module Telegram
  class MessageEntity < BaseModel
    attr_accessor :offset, :length, :type
  end
end
