# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Handlers::MentionHandler do
  let(:chat_id) { 123456 }
  let(:chat) { double('Chat', telegram_chat_id: chat_id, private?: false) }
  let(:user) { double('User') }
  let(:msg) { instance_double(Telegram::Types::Message, text: text, entities: entities) }
  let(:tg_update) { instance_double(Telegram::Types::UpdateFullData, message: msg) }
  let(:text) { '@test_bot http://example.com' }
  let(:entities) { [instance_double(Telegram::Types::MessageEntity, type: 'mention', offset: 0, length: 9)] }

  subject { described_class.new(chat, user, tg_update) }

  before do
    allow(Telegram::Handlers::UrlHandler).to receive(:call)
    allow(TelegramClient).to receive(:send_message)
    stub_const('Telegram::Handlers::BaseHandler::TELEGRAM_BOT_NAME', '@test_bot')
  end

  describe '#call' do
    context 'when URL is present' do
      let(:text) { '@test_bot https://www.youtube.com/watch?v=dQw4w9WgXcQ' }

      it 'calls UrlHandler' do
        subject.call
        expect(Telegram::Handlers::UrlHandler).to have_received(:call).with(chat, user, tg_update)
      end

      it 'does not send default text message' do
        subject.call
        expect(TelegramClient).not_to have_received(:send_message)
      end
    end

    context 'when URL is NOT present' do
      let(:text) { '@test_bot hello' }

      it 'sends no_url error and does NOT call super/UrlHandler' do
        subject.call
        expect(Telegram::Handlers::UrlHandler).not_to have_received(:call)
        expect(TelegramClient).to have_received(:send_message).once.with(
          chat_id: chat_id,
          text: I18n.t('telegram.handlers.download.errors.no_url')
        )
        expect(TelegramClient).not_to have_received(:send_message).with(
          chat_id: chat_id,
          text: I18n.t('telegram.handlers.text_handler.message')
        )
      end
    end

    context 'in private chat' do
      let(:chat) { double('Chat', telegram_chat_id: chat_id, private?: true) }

      context 'when text starts with bot name' do
        let(:text) { '@test_bot http://example.com' }

        it 'calls UrlHandler' do
          subject.call
          expect(Telegram::Handlers::UrlHandler).to have_received(:call).with(chat, user, tg_update)
        end
      end

      context 'when text does not start with bot name' do
        let(:text) { 'http://example.com' }
        let(:entities) { [] }

        it 'does not call UrlHandler' do
          subject.call
          expect(Telegram::Handlers::UrlHandler).not_to have_received(:call)
        end
      end
    end

    context 'when mention is for another user' do
      let(:text) { '@another_bot http://example.com' }
      let(:entities) { [instance_double(Telegram::Types::MessageEntity, type: 'mention', offset: 0, length: 12)] }

      it 'does not call UrlHandler and does not send any message' do
        subject.call
        expect(Telegram::Handlers::UrlHandler).not_to have_received(:call)
        expect(TelegramClient).not_to have_received(:send_message)
      end
    end
  end
end
