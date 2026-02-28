# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Handlers::DocumentHandler do
  let(:chat_id) { 123456 }
  let(:chat) do
    Chat.create!(
      telegram_chat_id: chat_id,
      username: 'test_user',
      chat_type: 'private'
    )
  end
  let(:user) { User.create!(telegram_user_id: 1, username: 'user') }
  let(:file_id) { 'file_123' }
  let(:file_size) { 10.megabytes }
  let(:document) { instance_double(Telegram::Types::Document, file_id: file_id, file_size: file_size) }
  let(:msg) { instance_double(Telegram::Types::Message, document: document, text: nil) }
  let(:tg_update) { instance_double(Telegram::Types::UpdateFullData, message: msg) }
  let(:file_url) { 'https://api.telegram.org/file/file_123' }

  subject { described_class.new(chat, user, tg_update) }

  before do
    allow(DownloadJob).to receive(:perform_later)
    allow(TelegramClient).to receive(:send_message)
    allow(TelegramClient).to receive(:get_file_path).with(file_id).and_return(file_url)
  end

  describe '#call' do
    it 'creates a Download record using file path and enqueues job' do
      expect { subject.call }.to change(Download, :count).by(1)

      download = Download.last
      expect(download.url).to eq(file_url)
      expect(download.chat).to eq(chat)
      expect(download.status).to eq('queued')

      expect(DownloadJob).to have_received(:perform_later).with(download.id)
    end

    context 'when file is too big' do
      let(:file_size) { described_class::ALLOWED_MAX_FILE_SIZE + 1 }

      it 'does not create download and notifies user' do
        expect { subject.call }.not_to change(Download, :count)

        expect(TelegramClient).to have_received(:send_message).with(
          chat_id: chat_id,
          text: I18n.t(
            'telegram.handlers.download.errors.file_too_big',
            limit_size: ActiveSupport::NumberHelper.number_to_human_size(described_class::ALLOWED_MAX_FILE_SIZE),
            file_size: ActiveSupport::NumberHelper.number_to_human_size(file_size)
          )
        )
      end
    end

    context 'when file_id is missing' do
      let(:file_id) { nil }

      it 'does not create download and notifies user' do
        expect { subject.call }.not_to change(Download, :count)

        expect(TelegramClient).to have_received(:send_message).with(
          chat_id: chat_id,
          text: I18n.t('telegram.handlers.download.errors.no_url')
        )
      end
    end

    context 'when Telegram client fails to send' do
      let(:error) { TelegramClient::ResponseError.new('fail', 400) }

      before do
        allow(TelegramClient).to receive(:get_file_path).and_raise(error)
      end

      it 'sends localized error message and re-raises' do
        expect {
          subject.call
        }.to raise_error(TelegramClient::ResponseError)

        expect(TelegramClient).to have_received(:send_message).with(
          chat_id: chat_id,
          text: I18n.t('telegram.handlers.download.errors.telegram_error', error: 'fail')
        )
      end
    end
  end
end
