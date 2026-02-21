# frozen_string_literal: true

module Telegram
  class User < BaseModel
    attr_accessor :id, :first_name, :last_name, :username, :is_bot, :is_premium, :language_code
  end
end
