# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Handlers::BotCommandHandler do
  let(:chat_id) { 123456 }
  let(:user) { double('User', telegram_user_id: 789, username: 'testuser') }
  let(:msg) { instance_double(Telegram::Message, text: text) }
  let(:text) { '/start' }

  subject { described_class.new(chat_id, msg, user) }

  before do
    allow(TelegramClient).to receive(:send_message)
  end

  describe '#call' do
    context 'when command is /start' do
      let(:text) { '/start' }

      it 'sends start message' do
        subject.call
        expect(TelegramClient).to have_received(:send_message).with(
          chat_id: chat_id,
          text: I18n.t('telegram.handlers.start_command.message')
        )
      end
    end

    context 'when command is /whoami' do
      let(:text) { '/whoami' }

      it 'sends user info' do
        subject.call
        expect(TelegramClient).to have_received(:send_message).with(
          chat_id: chat_id,
          text: I18n.t(
            'telegram.handlers.whoami_command.message',
            telegram_id: user.telegram_user_id,
            username: user.username
          )
        )
      end
    end

    context 'when command is unknown' do
      let(:text) { '/unknown' }

      it 'sends unknown command message' do
        subject.call
        expect(TelegramClient).to have_received(:send_message).with(
          chat_id: chat_id,
          text: I18n.t('telegram.handlers.errors.unknown_command')
        )
      end
    end
  end
end
