# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Types::Video do
  subject do
    described_class.new(
      file_id: 'video_1',
      duration: 60,
      width: 1920,
      height: 1080
    )
  end

  it 'assigns video attributes' do
    expect(subject.file_id).to eq('video_1')
    expect(subject.duration).to eq(60)
    expect(subject.width).to eq(1920)
    expect(subject.height).to eq(1080)
  end
end
