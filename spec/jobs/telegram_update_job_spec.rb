# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TelegramUpdateJob, type: :job do
  let(:chat_id) { 123 }
  let(:tg_user_id) { 456 }
  let(:user_allowed) { true }
  let(:user) do
    User.create!(
      telegram_user_id: tg_user_id,
      username: 'test_user',
      allowed: user_allowed
    )
  end
  let(:chat_title) { 'Test Chat' }
  let(:chat_username) { 'chat_user' }
  let(:chat_first_name) { 'Chat' }
  let(:chat_last_name) { 'User' }
  let(:chat_type) { 'private' }
  let(:update_hash) do
    {
      update_id: 1,
      message: {
        message_id: 10,
        date: Time.now.to_i,
        chat: {
          id: chat_id,
          type: chat_type,
          title: chat_title,
          username: chat_username,
          first_name: chat_first_name,
          last_name: chat_last_name
        },
        from: {
          id: tg_user_id,
          first_name: 'Test',
          last_name: 'User',
          username: 'test_user',
          language_code: 'en'
        },
        text: 'hi'
      }
    }
  end

  before do
    allow(TelegramClient).to receive(:send_message)
  end

  describe '#perform' do
    context 'when message is missing' do
      let(:update_hash) { { update_id: 1 } }

      it 'returns early without calling handlers' do
        expect(Telegram::Handlers::TextHandler).not_to receive(:call)
        described_class.perform_now(update_hash)
      end
    end

    context 'when handler is not found' do
      let(:update_hash) { super().deep_merge(message: { entities: [{ type: 'unknown' }] }) }

      it 'returns early without creating users or chats' do
        user_count = User.count
        chat_count = Chat.count

        expect(Telegram::Handlers::TextHandler).not_to receive(:call)
        described_class.perform_now(update_hash)

        expect(User.count).to eq(user_count)
        expect(Chat.count).to eq(chat_count)
      end
    end

    context 'when user is allowed' do
      let(:user_allowed) { true }

      before { user }

      it 'calls handler' do
        expect(Telegram::Handlers::TextHandler).to receive(:call).with(
          instance_of(Chat),
          user,
          instance_of(Telegram::Types::UpdateFullData)
        )
        described_class.perform_now(update_hash)
      end
    end

    context 'when user is not allowed' do
      let(:user_allowed) { false }

      before { user }

      it 'sends not allowed message and does not call handler' do
        expect(Telegram::Handlers::TextHandler).not_to receive(:call)

        described_class.perform_now(update_hash)

        expect(TelegramClient).to have_received(:send_message).with(
          chat_id: chat_id,
          text: I18n.t('telegram.handlers.errors.not_allowed', telegram_id: user.telegram_user_id)
        )
      end
    end

    context 'when chat does not exist' do
      before { user }

      it 'creates chat with attributes from telegram payload' do
        expect { described_class.perform_now(update_hash) }.to change(Chat, :count).by(1)

        db_chat = Chat.last
        expect(db_chat.telegram_chat_id).to eq(chat_id)
        expect(db_chat.title).to eq(chat_title)
        expect(db_chat.username).to eq(chat_username)
        expect(db_chat.first_name).to eq(chat_first_name)
        expect(db_chat.last_name).to eq(chat_last_name)
      end
    end
  end
end
