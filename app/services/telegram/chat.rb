# frozen_string_literal: true

module Telegram
  class Chat < BaseModel
    attr_accessor :id, :type, :username, :first_name, :last_name
  end
end
