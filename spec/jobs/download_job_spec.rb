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
    end

    it 'calls YtdlpDownloader with correct audio_only parameter from download record' do
      expect(YtdlpDownloader).to receive(:new).with(
        download.url,
        download_dir: /user_#{user.id}\z/,
        audio_only: true
      )

      DownloadJob.perform_now(download.id)
    end

    it 'updates download status to done' do
      DownloadJob.perform_now(download.id)
      expect(download.reload.status).to eq('done')
      expect(download.output_path).to eq('/path/to/file.mp3')
    end
  end
end
