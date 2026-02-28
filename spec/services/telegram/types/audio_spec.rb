# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Types::Audio do
  subject do
    described_class.new(
      file_id: 'audio_1',
      duration: 120,
      performer: 'Artist',
      title: 'Song'
    )
  end

  it 'assigns audio attributes' do
    expect(subject.file_id).to eq('audio_1')
    expect(subject.duration).to eq(120)
    expect(subject.performer).to eq('Artist')
    expect(subject.title).to eq('Song')
  end
end
