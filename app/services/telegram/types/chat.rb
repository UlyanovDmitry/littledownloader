# frozen_string_literal: true

module Telegram
  module Types
    class Chat < BaseType
      attr_accessor :id, :type, :username, :first_name, :last_name, :title, :all_members_are_administrators, :accepted_gift_types
    end
  end
end
