# frozen_string_literal: true

module Telegram
  class Webhook < BaseModel
    attr_accessor :update_id

    def message
      @message ||= Message.new extra_attributes[:message]
    end
  end
end
