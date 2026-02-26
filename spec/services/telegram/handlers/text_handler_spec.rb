# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Handlers::TextHandler do
  let(:chat_id) { 123456 }
  let(:user) { double('User') }
  let(:msg) { instance_double(Telegram::Message, text: text) }
  let(:text) { 'some text' }

  subject { described_class.new(chat_id, msg, user) }

  before do
    allow(TelegramClient).to receive(:send_message)
  end

  describe '#call' do
    context 'when text is present' do
      it 'sends default text message' do
        subject.call
        expect(TelegramClient).to have_received(:send_message).with(
          chat_id: chat_id,
          text: I18n.t('telegram.handlers.text_handler.message')
        )
      end
    end

    context 'when text is blank' do
      let(:text) { '' }

      it 'does nothing' do
        subject.call
        expect(TelegramClient).not_to have_received(:send_message)
      end
    end
  end
end
