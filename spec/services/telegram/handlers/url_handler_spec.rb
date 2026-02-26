# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Handlers::UrlHandler do
  let(:chat_id) { 123456 }
  let(:user) { double('User') }
  let(:msg) { instance_double(Telegram::Message) }

  subject { described_class.new(chat_id, msg, user) }

  describe '#call' do
    let(:url) { 'https://youtube.com/watch?v=123' }
    let(:msg) { instance_double(Telegram::Message, text: url) }

    it 'calls YtdlpDownloader with correct url and default audio_only' do
      downloader = instance_double(YtdlpDownloader)
      expect(YtdlpDownloader).to receive(:new).with(url, audio_only: false).and_return(downloader)
      expect(downloader).to receive(:download)

      subject.call
    end

    context 'when message contains audio-only' do
      let(:msg) { instance_double(Telegram::Message, text: "#{url} audio-only") }

      it 'calls YtdlpDownloader with audio_only: true' do
        downloader = instance_double(YtdlpDownloader)
        expect(YtdlpDownloader).to receive(:new).with(url, audio_only: true).and_return(downloader)
        expect(downloader).to receive(:download)

        subject.call
      end
    end
  end
end
