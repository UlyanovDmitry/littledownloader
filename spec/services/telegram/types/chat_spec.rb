# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Types::Chat do
  subject do
    described_class.new(
      id: 1,
      type: chat_type,
      title: 'Test Group',
      username: 'chat_user',
      first_name: 'Chat',
      last_name: 'User'
    )
  end

  let(:chat_type) { 'private' }

  it 'assigns chat attributes' do
    expect(subject.id).to eq(1)
    expect(subject.type).to eq('private')
    expect(subject.title).to eq('Test Group')
    expect(subject.username).to eq('chat_user')
    expect(subject.first_name).to eq('Chat')
    expect(subject.last_name).to eq('User')
  end
end
