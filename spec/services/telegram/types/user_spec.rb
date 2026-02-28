# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Types::User do
  let(:attributes) do
    {
      id: 123,
      first_name: 'John',
      last_name: 'Doe',
      username: 'jdoe',
      is_bot: false,
      is_premium: true,
      language_code: 'en'
    }
  end
  subject { described_class.new(attributes) }

  it 'has correct attributes' do
    expect(subject.id).to eq(123)
    expect(subject.first_name).to eq('John')
    expect(subject.last_name).to eq('Doe')
    expect(subject.username).to eq('jdoe')
    expect(subject.is_bot).to be false
    expect(subject.is_premium).to be true
    expect(subject.language_code).to eq('en')
  end
end
