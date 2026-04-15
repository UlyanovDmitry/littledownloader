# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Handlers::BotCommandHandler do
  let(:chat_id) { 123456 }
  let(:chat) { Chat.create!(telegram_chat_id: chat_id, chat_type: 'private') }
  let(:user) { User.create!(telegram_user_id: 789, username: 'testuser') }
  let(:msg) { instance_double(Telegram::Types::Message, text: text, entities: entities) }
  let(:tg_update) { instance_double(Telegram::Types::UpdateFullData, message: msg) }
  let(:text) { '/start' }
  let(:entities) { [instance_double(Telegram::Types::MessageEntity, type: 'bot_command', offset: 0, length: text.length)] }

  subject { described_class.new(chat, user, tg_update) }

  before do
    allow(TelegramClient).to receive(:send_message)
    stub_const('Telegram::Handlers::BaseHandler::TELEGRAM_BOT_NAME', '@test_bot')
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

    context 'when command is /help' do
      let(:text) { '/help' }

      it 'sends help message' do
        subject.call
        expect(TelegramClient).to have_received(:send_message).with(
          chat_id: chat_id,
          text: I18n.t('telegram.handlers.help_command.message')
        )
      end
    end

    context 'when command is /my_info' do
      let(:text) { '/my_info' }

      before do
        Download.create!(url: 'http://e.com', chat: chat, user: user, status: :done, file_size: 3072)
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

    context 'when command includes bot name' do
      let(:text) { '/start@test_bot' }

      it 'sends start message' do
        subject.call
        expect(TelegramClient).to have_received(:send_message).with(
          chat_id: chat_id,
          text: I18n.t('telegram.handlers.start_command.message')
        )
      end
    end

    context 'when bot command is not at the beginning' do
      let(:text) { 'check this /start command' }
      let(:entities) { [instance_double(Telegram::Types::MessageEntity, type: 'bot_command', offset: 11, length: 6)] }

      it 'correctly extracts and performs the command' do
        subject.call
        expect(TelegramClient).to have_received(:send_message).with(
          chat_id: chat_id,
          text: I18n.t('telegram.handlers.start_command.message')
        )
      end
    end

    context 'when no bot_command entity is present' do
      let(:text) { '/start' }
      let(:entities) { [] }

      it 'sends unknown command message' do
        subject.call
        expect(TelegramClient).to have_received(:send_message).with(
          chat_id: chat_id,
          text: I18n.t('telegram.handlers.errors.unknown_command')
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
