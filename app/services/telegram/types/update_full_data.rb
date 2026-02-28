# frozen_string_literal: true

module Telegram
  module Types
    class UpdateFullData < BaseType
      attr_accessor :update_id

      deep_objects :Message, :Webhook
    end
  end
end
