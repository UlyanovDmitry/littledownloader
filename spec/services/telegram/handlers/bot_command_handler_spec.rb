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

    context 'when command is /info' do
      let(:text) { '/info' }
      let(:user) { User.create!(telegram_user_id: 789, username: 'testuser') }

      before do
        user.downloads.create!(url: 'url1', chat_id: chat_id, status: :done, file_size: 1024, audio_only: false)
        user.downloads.create!(url: 'url2', chat_id: chat_id, status: :done, file_size: 2048, audio_only: false)
        user.downloads.create!(url: 'url3', chat_id: chat_id, status: :failed, file_size: 5000, audio_only: false)
      end

      it 'sends user info with disk usage' do
        subject.call
        expect(TelegramClient).to have_received(:send_message).with(
          chat_id: chat_id,
          text: I18n.t(
            'telegram.handlers.info_command.message',
            telegram_id: user.telegram_user_id,
            username: user.username,
            disk_usage: '3 KB'
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
