# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Chat, type: :model do
  let(:chat) { described_class.new(telegram_chat_id: 123, chat_type: 'private') }

  describe 'validations' do
    it 'is valid with telegram_chat_id' do
      expect(chat).to be_valid
    end

    it 'is invalid without telegram_chat_id' do
      chat.telegram_chat_id = nil
      expect(chat).not_to be_valid
      expect(chat.errors[:telegram_chat_id]).to be_present
    end

    it 'enforces uniqueness of telegram_chat_id' do
      described_class.create!(telegram_chat_id: 123)

      duplicate = described_class.new(telegram_chat_id: 123)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:telegram_chat_id]).to be_present
    end
  end

  describe '#private?' do
    it 'returns true for private chats' do
      expect(chat.private?).to be true
    end

    it 'returns false for non-private chats' do
      chat.chat_type = 'group'
      expect(chat.private?).to be false
    end
  end
end
