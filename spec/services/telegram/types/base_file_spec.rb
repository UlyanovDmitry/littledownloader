# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Types::BaseFile do
  subject do
    described_class.new(
      file_id: 'file_1',
      file_size: 123,
      file_name: 'video.mp4',
      mime_type: 'video/mp4',
      unknown: 'extra'
    )
  end

  it 'assigns known attributes' do
    expect(subject.file_id).to eq('file_1')
    expect(subject.file_size).to eq(123)
    expect(subject.file_name).to eq('video.mp4')
    expect(subject.mime_type).to eq('video/mp4')
  end

  it 'stores unknown attributes in extra_attributes' do
    expect(subject.extra_attributes[:unknown]).to eq('extra')
  end
end
