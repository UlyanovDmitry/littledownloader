# frozen_string_literal: true

module Telegram
  class BaseModel
    include ActiveModel::AttributeAssignment
    attr_reader :extra_attributes
    def self.deep_objects(*obj_names)
      obj_names.each do |obj_name|
        method_name = obj_name.to_s.underscore

        define_method "#{method_name}=" do |attributes|
          klass = "Telegram::#{obj_name}".safe_constantize || obj_name.to_s.constantize
          value = attributes.is_a?(Hash) ? klass.new(attributes) : attributes
          instance_variable_set("@#{method_name}", value)
        end

        attr_reader method_name.to_sym
      end
    end
    private_class_method :deep_objects

    def initialize(attributes = {})
      @extra_attributes = {}

      assign_attributes(attributes) if attributes
    end

    private

    def attribute_writer_missing(name, value)
      @extra_attributes[name.to_sym] = value
    end
  end
end
