# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Types::Message do
  let(:attributes) do
    {
      message_id: 1,
      text: 'hello',
      from: { id: 123, first_name: 'John' },
      entities: [
        { type: 'bot_command', offset: 0, length: 6 }
      ]
    }
  end
  subject { described_class.new(attributes) }

  describe '#from' do
    it 'returns a Telegram::User' do
      expect(subject.from).to be_a(Telegram::Types::User)
      expect(subject.from.id).to eq(123)
      expect(subject.from.first_name).to eq('John')
    end
  end

  describe '#entities' do
    it 'returns an array of Telegram::MessageEntity' do
      expect(subject.entities).to be_an(Array)
      expect(subject.entities.first).to be_a(Telegram::Types::MessageEntity)
      expect(subject.entities.first.type).to eq('bot_command')
    end
  end

  describe '#type' do
    it 'returns the type of the first entity' do
      expect(subject.type).to eq(:bot_command)
    end

    it 'returns :text if no entities' do
      msg = described_class.new(text: 'plain text')
      expect(msg.type).to eq(:text)
    end
  end

  describe 'dynamic type methods' do
    it 'responds to type_? methods' do
      expect(subject.type_bot_command?).to be true
      expect(subject.type_url?).to be false
    end
  end
end
