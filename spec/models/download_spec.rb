require 'rails_helper'

RSpec.describe Download, type: :model do
  let(:user) { User.create!(telegram_user_id: 123, username: 'testuser') }
  let(:valid_attributes) do
    {
      user: user,
      chat_id: 456,
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      status: :queued,
      audio_only: false
    }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(Download.new(valid_attributes)).to be_valid
    end

    it 'is invalid without url' do
      expect(Download.new(valid_attributes.merge(url: nil))).not_to be_valid
    end

    it 'is invalid without chat_id' do
      expect(Download.new(valid_attributes.merge(chat_id: nil))).not_to be_valid
    end

    it 'is invalid without status' do
      expect(Download.new(valid_attributes.merge(status: nil))).not_to be_valid
    end

    it 'is invalid without user' do
      expect(Download.new(valid_attributes.merge(user: nil))).not_to be_valid
    end

    it 'is invalid if audio_only is not boolean' do
      expect(Download.new(valid_attributes.merge(audio_only: nil))).not_to be_valid
    end
  end

  describe 'defaults' do
    it 'sets default status to queued' do
      download = Download.new(user: user, chat_id: 456, url: 'http://example.com')
      expect(download.status).to eq('queued')
    end

    it 'sets default audio_only to false if not specified (via DB/Model)' do
      download = Download.create!(user: user, chat_id: 456, url: 'http://example.com')
      expect(download.audio_only).to be false
    end
  end
end
