# frozen_string_literal: true

module Telegram
  module Types
    class Message < BaseType
      attr_accessor :message_id, :date, :text, :forward_origin, :forward_date, :forward_from

      alias :to_s :text

      deep_objects :Chat, :Document, :Video, :Audio
      def from
        @from ||= User.new extra_attributes[:from]
      end
      alias :user :from

      def entities
        return [] unless extra_attributes[:entities].present?

        @entities ||= extra_attributes[:entities].map { |entity| MessageEntity.new(entity) }
      end

      def type
        @type ||= if document.present?
                    :document
        elsif video.present?
                    :video
        elsif audio.present?
                    :audio
        else
                    main_entity&.type&.to_sym || :text
        end
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
end
