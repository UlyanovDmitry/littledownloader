# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Handlers::MentionHandler do
  let(:chat_id) { 123456 }
  let(:chat) { Chat.create!(telegram_chat_id: chat_id, chat_type: is_private ? 'private' : 'group') }
  let(:is_private) { false }
  let(:user) { User.create!(telegram_user_id: 123, username: 'testuser') }
  let(:msg) { instance_double(Telegram::Types::Message, text: text, entities: entities) }
  let(:tg_update) { instance_double(Telegram::Types::UpdateFullData, message: msg) }
  let(:text) { '@test_bot https://www.youtube.com/watch?v=dQw4w9WgXcQ' }
  let(:entities) do
    [
      instance_double(Telegram::Types::MessageEntity, type: 'mention', offset: 0, length: 9),
      instance_double(Telegram::Types::MessageEntity, type: 'url', offset: 10, length: 43)
    ]
  end

  subject { described_class.new(chat, user, tg_update) }

  before do
    allow(Telegram::Handlers::UrlHandler).to receive(:call).and_call_original
    allow(Telegram::Handlers::TextHandler).to receive(:call)
    allow(TelegramClient).to receive(:send_message)
    allow(DownloadJob).to receive(:perform_later)
    stub_const('Telegram::Handlers::BaseHandler::TELEGRAM_BOT_NAME', '@test_bot')
  end

  describe '#call' do
    context 'when URL is present' do
      let(:text) { '@test_bot https://www.youtube.com/watch?v=dQw4w9WgXcQ' }
      let(:entities) do
        [
          instance_double(Telegram::Types::MessageEntity, type: 'mention', offset: 0, length: 9),
          instance_double(Telegram::Types::MessageEntity, type: 'url', offset: 10, length: 43)
        ]
      end

      it 'creates a Download and enqueues Job' do
        expect(DownloadJob).to receive(:perform_later)

        expect { subject.call }.to change(Download, :count).by(1)

        download = Download.last
        expect(download.url).to eq('https://www.youtube.com/watch?v=dQw4w9WgXcQ')
        expect(download.chat).to eq(chat)
        expect(download.user).to eq(user)
      end

      it 'sends queued message' do
        subject.call
        expect(TelegramClient).to have_received(:send_message).with(
          chat_id: chat_id,
          text: /Accepted. Download queued./
        )
      end
    end

    context 'when URL is NOT present' do
      let(:text) { '@test_bot hello' }
      let(:entities) { [instance_double(Telegram::Types::MessageEntity, type: 'mention', offset: 0, length: 9)] }

      it 'sends default text message' do
        subject.call
        expect(TelegramClient).to have_received(:send_message).with(
          chat_id: chat_id,
          text: /Send a video link/
        )
      end
    end

    context 'in private chat' do
      let(:is_private) { true }

      context 'when text starts with bot name' do
        let(:text) { '@test_bot http://example.com' }
        let(:entities) do
          [
            instance_double(Telegram::Types::MessageEntity, type: 'mention', offset: 0, length: 9),
            instance_double(Telegram::Types::MessageEntity, type: 'url', offset: 10, length: 18)
          ]
        end

        it 'creates a download' do
          expect { subject.call }.to change(Download, :count).by(1)
        end
      end

      context 'when text does not start with bot name' do
        let(:text) { 'http://example.com' }
        let(:entities) { [] }

        it 'does not create a download' do
          expect(Download).not_to receive(:create!)
          subject.call
        end
      end
    end

    context 'when mention is for another user' do
      let(:text) { '@another_bot http://example.com' }
      let(:entities) { [instance_double(Telegram::Types::MessageEntity, type: 'mention', offset: 0, length: 12)] }

      it 'does not call any handler and does not send any message' do
        expect(Download).not_to receive(:create!)
        subject.call
        expect(Telegram::Handlers::TextHandler).not_to have_received(:call)
        expect(TelegramClient).not_to have_received(:send_message)
      end
    end

    context 'when bot name is prefix of another bot name (issue reproduction)' do
      let(:text) { '@test_botnews http://example.com' }
      let(:entities) { [instance_double(Telegram::Types::MessageEntity, type: 'mention', offset: 0, length: 13)] }

      it 'does not call any handler and does not send any message' do
        expect(Download).not_to receive(:create!)
        subject.call
        expect(TelegramClient).not_to have_received(:send_message)
      end
    end

    context 'when mention is a prefix of bot name (regression test)' do
      let(:text) { '@test http://example.com' }
      let(:entities) { [instance_double(Telegram::Types::MessageEntity, type: 'mention', offset: 0, length: 5)] }

      it 'does not call any handler and does not send any message' do
        expect(Download).not_to receive(:create!)
        subject.call
        expect(TelegramClient).not_to have_received(:send_message)
      end
    end

    context 'with emoji in text (Unicode offset fix)' do
      let(:text) { '🚀 @test_bot https://example.com' }
      let(:entities) do
        [
          instance_double(Telegram::Types::MessageEntity, type: 'mention', offset: 3, length: 9),
          instance_double(Telegram::Types::MessageEntity, type: 'url', offset: 13, length: 19)
        ]
      end

      it 'correctly identifies the bot mention and extracts the URL' do
        expect { subject.call }.to change(Download, :count).by(1)
        expect(Download.last.url).to eq('https://example.com')
      end
    end
  end
end
