# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Handlers::BotCommandHandler do
  let(:chat_id) { 123456 }
  let(:chat) { double('Chat', telegram_chat_id: chat_id) }
  let(:user) { double('User', telegram_user_id: 789, username: 'testuser') }
  let(:msg) { instance_double(Telegram::Types::Message, text: text) }
  let(:tg_update) { instance_double(Telegram::Types::UpdateFullData, message: msg) }
  let(:text) { '/start' }

  subject { described_class.new(chat, user, tg_update) }

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

    context 'when command is /my_info' do
      let(:text) { '/my_info' }
      let(:user) { User.create!(telegram_user_id: 789, username: 'testuser') }
      let(:chat) do
        Chat.create!(
          telegram_chat_id: chat_id,
          username: 'test_user',
          chat_type: 'private'
        )
      end

      before do
        user.downloads.create!(url: 'url1', chat: chat, status: :done, file_size: 1024, audio_only: false)
        user.downloads.create!(url: 'url2', chat: chat, status: :done, file_size: 2048, audio_only: false)
        user.downloads.create!(url: 'url3', chat: chat, status: :failed, file_size: 5000, audio_only: false)
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
