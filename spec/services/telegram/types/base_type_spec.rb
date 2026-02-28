# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Types::BaseType do
  let(:test_class) do
    Class.new(described_class) do
      attr_accessor :name
    end
  end

  describe '#initialize' do
    it 'assigns known attributes' do
      instance = test_class.new(name: 'Test')
      expect(instance.name).to eq('Test')
    end

    it 'stores unknown attributes in extra_attributes' do
      instance = test_class.new(unknown: 'Value')
      expect(instance.extra_attributes[:unknown]).to eq('Value')
    end
  end

  describe '.deep_objects' do
    before do
      stub_const('Telegram::Types::Nested', Class.new(described_class) do
        attr_accessor :foo
      end)
    end

    let(:test_class_with_deep) do
      Class.new(described_class) do
        deep_objects :Nested
      end
    end

    it 'creates a reader and a writer that instantiates the class' do
      instance = test_class_with_deep.new(nested: { foo: 'bar' })
      expect(instance.nested).to be_a(Telegram::Types::Nested)
      expect(instance.nested.foo).to eq('bar')
    end
  end
end
