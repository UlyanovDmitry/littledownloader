require 'rails_helper'
require 'tmpdir'

RSpec.describe Downloads::SoftDeleteService do
  let(:user) { User.create!(telegram_user_id: 123, username: 'testuser') }
  let(:chat) do
    Chat.create!(
      telegram_chat_id: 456,
      username: 'test_user',
      chat_type: 'private'
    )
  end

  describe '.by_uuid!' do
    it 'marks record as deleted and moves file to trash directory' do
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

        deleted_count = described_class.by_uuid!(download.id)

        expect(deleted_count).to eq(1)
        expect(Download.find_by(id: download.id)).to be_nil

        deleted_download = Download.only_deleted.find(download.id)
        expect(deleted_download.deleted_at).to be_present
        expect(deleted_download.output_path).to include('/trash/')
        expect(File.exist?(source_path)).to be(false)
        expect(File.exist?(deleted_download.output_path)).to be(true)
      end
    end
  end

  describe '.by_user!' do
    it 'soft deletes all user downloads' do
      user_download_1 = Download.create!(user: user, chat: chat, url: 'https://example.com/1', audio_only: false)
      user_download_2 = Download.create!(user: user, chat: chat, url: 'https://example.com/2', audio_only: false)
      other_user = User.create!(telegram_user_id: 999, username: 'other')
      active_other = Download.create!(user: other_user, chat: chat, url: 'https://example.com/3', audio_only: false)

      deleted_count = described_class.by_user!(user.id)

      expect(deleted_count).to eq(2)
      expect(Download.only_deleted.pluck(:id)).to include(user_download_1.id, user_download_2.id)
      expect(Download.exists?(active_other.id)).to be(true)
    end
  end
end
