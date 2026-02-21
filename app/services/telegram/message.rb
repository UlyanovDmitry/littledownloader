# frozen_string_literal: true

module Telegram
  class Message < BaseModel
    attr_accessor :message_id, :date, :text

    alias :to_s :text

    deep_objects :Chat
    def from
      @from ||= User.new extra_attributes[:from]
    end
    alias :user :from

    def entities
      return [] unless extra_attributes[:entities].present?

      @entities ||= extra_attributes[:entities].map { |entity| MessageEntity.new(entity) }
    end

    def type
      main_entity&.type&.to_sym || :text
    end

    private
    def method_missing(name, *args)
      if name.to_s.start_with?('type_')
        type == name.to_s.delete_prefix('type_').delete_suffix('?').to_sym
      else
        super
      end
    end
    def main_entity
      @main_entity ||= entities.first
    end
  end
end
