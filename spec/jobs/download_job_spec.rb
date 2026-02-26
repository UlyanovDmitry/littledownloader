require 'rails_helper'

RSpec.describe DownloadJob, type: :job do
  let(:user) { User.create!(telegram_user_id: 123, username: 'testuser') }
  let(:download) do
    Download.create!(
      user: user,
      chat_id: 456,
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      audio_only: true
    )
  end

  describe '#perform' do
    let(:downloader_double) { instance_double(YtdlpDownloader) }

    before do
      allow(YtdlpDownloader).to receive(:new).and_return(downloader_double)
      allow(downloader_double).to receive(:download).and_return('/path/to/file.mp3')
      allow(TelegramClient).to receive(:send_message)
    end

    it 'calls YtdlpDownloader with correct audio_only parameter from download record' do
      expect(YtdlpDownloader).to receive(:new).with(
        download.url,
        download_dir: /user_#{user.id}\z/,
        audio_only: true
      )

      DownloadJob.perform_now(download.id)
    end

    it 'updates download status to done, records file size and sends notification' do
      expect(File).to receive(:exist?).with('/path/to/file.mp3').and_return(true)
      expect(File).to receive(:size).with('/path/to/file.mp3').and_return(1234)

      expect(TelegramClient).to receive(:send_message).with(
        chat_id: 456,
        text: /✅ Download finished.*file.mp3/m
      )

      DownloadJob.perform_now(download.id)

      expect(download.reload.status).to eq('done')
      expect(download.output_path).to eq('/path/to/file.mp3')
      expect(download.file_size).to eq(1234)
    end

    it 'notifies admins on success, excluding the initiator' do
      User.create!(telegram_user_id: 999, username: 'admin', role: 'admin')
      user.update!(role: 'admin') # Initiator is also an admin

      expect(TelegramClient).to receive(:send_message).with(
        chat_id: 456,
        text: /✅ Download finished.*file.mp3/m
      )

      # Should only notify the other admin, not the initiator (chat_id: 123)
      expect(TelegramClient).to receive(:send_message).with(
        chat_id: 999,
        text: /✅ Download finished.*file.mp3.*testuser/m
      )

      expect(TelegramClient).not_to receive(:send_message).with(
        chat_id: 123,
        text: /✅ Download finished.*testuser/m
      )

      DownloadJob.perform_now(download.id)
    end

    it 'sends failure notification on error and notifies admins' do
      User.create!(telegram_user_id: 999, username: 'admin', role: 'admin')
      allow(downloader_double).to receive(:download).and_raise(StandardError, 'some error')

      expect(TelegramClient).to receive(:send_message).with(
        chat_id: 456,
        text: /❌ Download failed.*some error/m
      )

      # Notification for admins
      expect(TelegramClient).to receive(:send_message).with(
        chat_id: 999,
        text: /❌ Download failed.*some error.*testuser/m
      )

      expect {
        DownloadJob.perform_now(download.id)
      }.to raise_error(StandardError, 'some error')

      expect(download.reload.status).to eq('failed')
      expect(download.error).to eq('some error')
    end
  end
end
