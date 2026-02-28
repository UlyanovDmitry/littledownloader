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
  let(:update_hash) do
    {
      update_id: 1,
      message: {
        message_id: 10,
        date: Time.now.to_i,
        chat: { id: chat_id, type: 'private' },
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

      it 'returns early without creating users' do
        expect(Telegram::Handlers::TextHandler).not_to receive(:call)
        expect { described_class.perform_now(update_hash) }.not_to change(User, :count)
      end
    end

    context 'when user is allowed' do
      let(:user_allowed) { true }

      before { user }

      it 'calls handler' do
        expect(Telegram::Handlers::TextHandler).to receive(:call).with(
          chat_id,
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
  end
end
