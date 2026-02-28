# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Types::Document do
  subject { described_class.new(file_id: 'doc_1', file_size: 42) }

  it 'inherits base file attributes' do
    expect(subject.file_id).to eq('doc_1')
    expect(subject.file_size).to eq(42)
  end
end
