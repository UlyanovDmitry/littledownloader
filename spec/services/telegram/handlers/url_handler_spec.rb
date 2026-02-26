# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Handlers::UrlHandler do
  let(:chat_id) { 123456 }
  let(:user) { User.create!(telegram_user_id: 1, username: 'user') }
  let(:msg) { instance_double(Telegram::Message) }

  subject { described_class.new(chat_id, msg, user) }

  before do
    allow(DownloadJob).to receive(:perform_later)
    allow(TelegramClient).to receive(:send_message)
  end

  describe '#call' do
    let(:url) { 'https://youtube.com/watch?v=123' }
    let(:msg) { instance_double(Telegram::Message, text: url) }

    it 'creates a Download record, sends message and enqueues job' do
      expect { subject.call }.to change(Download, :count).by(1)

      download = Download.last
      expect(download.url).to eq(url)
      expect(download.audio_only).to be false
      expect(download.status).to eq('queued')

      expect(TelegramClient).to have_received(:send_message).with(
        chat_id: chat_id,
        text: /✅ Accepted. Download queued.\nID: #{download.id}/m
      )

      expect(DownloadJob).to have_received(:perform_later).with(download.id)
    end

    context 'when message contains audio-only' do
      let(:msg) { instance_double(Telegram::Message, text: "#{url} audio-only") }

      it 'creates Download with audio_only: true' do
        subject.call
        download = Download.last
        expect(download.audio_only).to be true
      end
    end
  end
end
