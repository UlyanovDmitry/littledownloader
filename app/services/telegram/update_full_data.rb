# frozen_string_literal: true

module Telegram
  class UpdateFullData < BaseModel
    attr_accessor :update_id

    deep_objects :Message, :Webhook
  end
end
