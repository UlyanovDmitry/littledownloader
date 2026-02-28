# frozen_string_literal: true

module Telegram
  module Types
    class Chat < BaseType
      attr_accessor :id, :type, :username, :first_name, :last_name
    end
  end
end
