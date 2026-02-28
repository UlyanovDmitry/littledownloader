require 'rails_helper'

RSpec.describe Downloads::Notifier do
  let(:user) { User.create!(telegram_user_id: 123, username: 'testuser') }
  let(:chat) do
    Chat.create!(
      telegram_chat_id: 456,
      username: 'test_user',
      chat_type: 'private'
    )
  end
  let(:download) do
    Download.create!(
      user: user,
      chat: chat,
      url: 'https://example.com/videos/watch?v=dQw4w',
      audio_only: true
    )
  end

  subject(:notifier) { described_class.new(download) }

  before do
    allow(TelegramClient).to receive(:send_message)
  end

  describe '#notify_success' do
    it 'notifies the user and other admins, excluding the initiator' do
      User.create!(telegram_user_id: 999, username: 'admin', role: 'admin')
      user.update!(role: 'admin')

      expect(TelegramClient).to receive(:send_message).with(
        chat_id: 456,
        text: /✅ Download finished.*file.mp3/m
      )
      expect(TelegramClient).to receive(:send_message).with(
        chat_id: 999,
        text: /✅ Download finished.*file.mp3.*testuser/m
      )
      expect(TelegramClient).not_to receive(:send_message).with(
        chat_id: 123,
        text: /✅ Download finished.*testuser/m
      )

      notifier.notify_success('file.mp3')
    end
  end

  describe '#notify_failure' do
    it 'sends simple failure notification for regular users' do
      User.create!(telegram_user_id: 999, username: 'admin', role: 'admin')
      error = YtdlpDownloader::DownloadError.new('some error')

      expect(TelegramClient).to receive(:send_message).with(
        chat_id: 456,
        text: /❌ Download failed\.\nID: #{download.id}/
      )
      expect(TelegramClient).to receive(:send_message).with(
        chat_id: 999,
        text: /❌ Download failed.*some error.*testuser/m
      )

      notifier.notify_failure(error)
    end

    it 'sends full failure notification for limit errors to regular users' do
      User.create!(telegram_user_id: 999, username: 'admin', role: 'admin')
      error = Downloads::LimitsChecker::DiskSpaceError.new('1 MB', '50 GB')

      expect(TelegramClient).to receive(:send_message).with(
        chat_id: 456,
        text: /❌ Download failed.*Disk free space below limit/m
      )
      expect(TelegramClient).to receive(:send_message).with(
        chat_id: 999,
        text: /❌ Download failed.*Disk free space below limit.*testuser/m
      )

      notifier.notify_failure(error)
    end

    it 'sends full failure notification for admin users' do
      user.update!(role: 'admin')
      error = StandardError.new('some error')

      expect(TelegramClient).to receive(:send_message).with(
        chat_id: 456,
        text: /❌ Download failed.*some error/m
      )

      notifier.notify_failure(error)
    end
  end
end
