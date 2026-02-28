require 'rails_helper'
require 'tmpdir'

RSpec.describe Downloads::RestoreService do
  let(:user) { User.create!(telegram_user_id: 123, username: 'testuser') }
  let(:chat) do
    Chat.create!(
      telegram_chat_id: 456,
      username: 'test_user',
      chat_type: 'private'
    )
  end

  describe '.by_uuid!' do
    it 'restores soft-deleted record and moves file out of trash directory' do
      Dir.mktmpdir do |tmp_dir|
        source_path = File.join(tmp_dir, 'song.mp3')
        File.write(source_path, 'content')

        download = Download.create!(
          user: user,
          chat: chat,
          url: 'https://example.com/video',
          status: :done,
          output_path: source_path,
          audio_only: false
        )

        Downloads::SoftDeleteService.by_uuid!(download.id)
        trashed_path = Download.only_deleted.find(download.id).output_path

        restored_count = described_class.by_uuid!(download.id)

        expect(restored_count).to eq(1)

        restored_download = Download.find(download.id)
        expect(restored_download.deleted_at).to be_nil
        expect(restored_download.output_path).to eq(source_path)
        expect(File.exist?(trashed_path)).to be(false)
        expect(File.exist?(source_path)).to be(true)
      end
    end
  end

  describe '.all!' do
    it 'restores all soft-deleted downloads' do
      first = Download.create!(user: user, chat: chat, url: 'https://example.com/1', audio_only: false)
      second = Download.create!(user: user, chat: chat, url: 'https://example.com/2', audio_only: false)

      Downloads::SoftDeleteService.by_uuid!(first.id)
      Downloads::SoftDeleteService.by_uuid!(second.id)

      restored_count = described_class.all!

      expect(restored_count).to eq(2)
      expect(Download.only_deleted.count).to eq(0)
      expect(Download.exists?(first.id)).to be(true)
      expect(Download.exists?(second.id)).to be(true)
    end
  end
end
