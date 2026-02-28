# frozen_string_literal: true

module Telegram
  module Types
    class User < BaseType
      attr_accessor :id, :first_name, :last_name, :username, :is_bot, :is_premium, :language_code
    end
  end
end
