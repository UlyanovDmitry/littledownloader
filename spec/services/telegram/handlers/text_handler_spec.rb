# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Handlers::TextHandler do
  let(:chat_id) { 123456 }
  let(:is_private) { true }
  let(:chat) { double('Chat', telegram_chat_id: chat_id, private?: is_private) }
  let(:user) { double('User') }
  let(:msg) { instance_double(Telegram::Types::Message, text: text, entities: entities) }
  let(:tg_update) { instance_double(Telegram::Types::UpdateFullData, message: msg) }
  let(:text) { 'some text' }
  let(:entities) { [] }

  subject { described_class.new(chat, user, tg_update) }

  before do
    allow(TelegramClient).to receive(:send_message)
    stub_const('Telegram::Handlers::BaseHandler::TELEGRAM_BOT_NAME', '@test_bot')
  end

  describe '#call' do
    context 'in private chat' do
      let(:is_private) { true }

      it 'sends default text message' do
        subject.call
        expect(TelegramClient).to have_received(:send_message).with(
          chat_id: chat_id,
          text: I18n.t('telegram.handlers.text_handler.message')
        )
      end

      context 'when starts with another mention' do
        let(:text) { '@another_user hello' }
        let(:entities) { [instance_double(Telegram::Types::MessageEntity, type: 'mention', offset: 0, length: 13)] }

        it 'does not send any message' do
          subject.call
          expect(TelegramClient).not_to have_received(:send_message)
        end
      end
    end

    context 'in group chat' do
      let(:is_private) { false }

      context 'when text starts with bot name' do
        let(:text) { '@test_bot hello' }
        let(:entities) { [instance_double(Telegram::Types::MessageEntity, type: 'mention', offset: 0, length: 9)] }

        it 'sends default text message' do
          subject.call
          expect(TelegramClient).to have_received(:send_message).with(
            chat_id: chat_id,
            text: I18n.t('telegram.handlers.text_handler.message')
          )
        end
      end

      context 'when text contains bot name in the middle' do
        let(:text) { 'hello @test_bot' }

        it 'does not send any message' do
          subject.call
          expect(TelegramClient).not_to have_received(:send_message)
        end
      end

      context 'when text does not start with bot name' do
        let(:text) { 'hello bot' }

        it 'does not send any message' do
          subject.call
          expect(TelegramClient).not_to have_received(:send_message)
        end
      end
    end
  end
end
