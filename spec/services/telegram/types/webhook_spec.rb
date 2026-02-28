# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Types::Webhook do
  subject do
    described_class.new(
      update_id: 9,
      message: { text: 'hook', from: { id: 321, first_name: 'Hook' } }
    )
  end

  it 'assigns update_id' do
    expect(subject.update_id).to eq(9)
  end

  it 'builds message from extra attributes' do
    expect(subject.message).to be_a(Telegram::Types::Message)
    expect(subject.message.text).to eq('hook')
    expect(subject.message.user).to be_a(Telegram::Types::User)
    expect(subject.message.user.id).to eq(321)
  end
end
