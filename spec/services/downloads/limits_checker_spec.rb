require 'rails_helper'

RSpec.describe Downloads::LimitsChecker do
  let(:user) { User.create!(telegram_user_id: 123, username: 'testuser') }
  let(:download) do
    Download.create!(
      user: user,
      chat_id: 456,
      url: 'https://example.com/videos/watch?v=dQw4w',
      audio_only: true
    )
  end

  subject(:checker) { described_class.new(download: download, base_dir: '/tmp/downloads') }

  describe '#call' do
    before do
      allow(checker).to receive(:disk_free_bytes).and_return(100 * 1024 * 1024 * 1024)
    end

    it 'passes when disk and quota limits are satisfied' do
      expect { checker.call }.not_to raise_error
    end

    it 'raises when disk free space is below limit' do
      stub_const('DownloadJob::DOWNLOADS_MIN_FREE_GB', 50)
      allow(checker).to receive(:disk_free_bytes).and_return(1 * 1024 * 1024)

      expect { checker.call }
        .to raise_error(Downloads::LimitsChecker::DiskSpaceError, /Disk free space below limit/)
    end

    it 'raises when user quota does not have enough headroom' do
      stub_const('DownloadJob::HEADROOM_BYTES', 2 * 1024 * 1024 * 1024)
      user.update!(storage_limit_bytes: 10 * 1024 * 1024 * 1024)
      Download.create!(
        user: user,
        chat_id: 456,
        url: 'https://example.com/videos/watch?v=dQw4w',
        audio_only: false,
        status: :done,
        file_size: 9 * 1024 * 1024 * 1024
      )

      expect { checker.call }
        .to raise_error(Downloads::LimitsChecker::LimitExceededError, /User storage limit reached/)
    end

    it 'skips disk check when free space cannot be determined' do
      allow(checker).to receive(:disk_free_bytes).and_return(nil)

      expect { checker.call }.not_to raise_error
    end
  end
end
