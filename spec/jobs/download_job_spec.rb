require 'rails_helper'

RSpec.describe DownloadJob, type: :job do
  let(:user) { User.create!(telegram_user_id: 123, username: 'testuser') }

  let(:chat) do
    Chat.create!(
      telegram_chat_id: 456,
      username: 'test_user',
      chat_type: chat_type
    )
  end
  let(:chat_type) { 'private' }
  let(:download) do
    Download.create!(
      user: user,
      chat: chat,
      url: 'https://example.com/videos/watch?v=dQw4w',
      audio_only: true
    )
  end

  describe '#perform' do
    let(:limits_checker) { instance_double(Downloads::LimitsChecker, call: true) }
    let(:downloader) { instance_double(YtdlpDownloader, download: '/path/to/file.mp3') }
    let(:notifier) { instance_double(Downloads::Notifier, notify_success: true, notify_failure: true) }

    before do
      allow(Downloads::LimitsChecker).to receive(:new).and_return(limits_checker)
      allow(YtdlpDownloader).to receive(:new).and_return(downloader)
      allow(Downloads::Notifier).to receive(:new).and_return(notifier)
      allow(File).to receive(:exist?).with('/path/to/file.mp3').and_return(true)
      allow(File).to receive(:size).with('/path/to/file.mp3').and_return(1234)
      allow(FileUtils).to receive(:mkdir_p)
    end

    it 'coordinates limits check, downloader, and success notification' do
      expect(Downloads::LimitsChecker).to receive(:new).with(
        download: download,
        base_dir: kind_of(String)
      ).and_return(limits_checker)
      expect(limits_checker).to receive(:call)
      expect(YtdlpDownloader).to receive(:new).with(
        download.url,
        download_dir: /user_#{user.id}\z/,
        audio_only: true
      ).and_return(downloader)
      expect(downloader).to receive(:download).and_return('/path/to/file.mp3')
      expect(Downloads::Notifier).to receive(:new).with(download).and_return(notifier)
      expect(notifier).to receive(:notify_success).with('file.mp3')

      described_class.perform_now(download.id)

      expect(download.reload.status).to eq('done')
      expect(download.output_path).to eq('/path/to/file.mp3')
      expect(download.file_size).to eq(1234)
    end

    it 'marks download as done and uses unknown filename when downloader returns non-string' do
      allow(downloader).to receive(:download).and_return(nil)

      expect(notifier).to receive(:notify_success).with('unknown')

      described_class.perform_now(download.id)

      expect(download.reload.status).to eq('done')
      expect(download.output_path).to be_blank
      expect(download.file_size).to be_nil
    end

    it 'does not store file_size when the downloaded file is missing' do
      allow(File).to receive(:exist?).with('/path/to/file.mp3').and_return(false)
      expect(File).not_to receive(:size)

      described_class.perform_now(download.id)

      expect(download.reload.status).to eq('done')
      expect(download.output_path).to eq('/path/to/file.mp3')
      expect(download.file_size).to be_nil
    end

    it 'marks download as failed and delegates failure notification when processing raises' do
      error = YtdlpDownloader::DownloadError.new('some error')
      allow(downloader).to receive(:download).and_raise(error)

      expect(notifier).to receive(:notify_failure).with(error)

      expect {
        described_class.perform_now(download.id)
      }.to raise_error(YtdlpDownloader::DownloadError, 'some error')

      expect(download.reload.status).to eq('failed')
      expect(download.error).to eq('some error')
    end

    it 're-raises errors when the download record no longer exists' do
      missing_id = download.id
      download.destroy!

      expect(Downloads::Notifier).not_to receive(:new)

      expect {
        described_class.perform_now(missing_id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'when chat is not private' do
      let(:chat_type) { 'group' }

      it 'uses chat directory for downloads' do
        expect(YtdlpDownloader).to receive(:new).with(
          download.url,
          download_dir: /chat_#{chat.id}\z/,
          audio_only: true
        ).and_return(downloader)

        described_class.perform_now(download.id)
      end
    end
  end
end
