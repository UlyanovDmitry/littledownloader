# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Types::UpdateFullData do
  let(:attributes) do
    {
      update_id: 1,
      message: { text: 'hello', from: { id: 123, first_name: 'John' } }
    }
  end

  subject { described_class.new(attributes) }

  it 'wraps message as Telegram::Types::Message' do
    expect(subject.message).to be_a(Telegram::Types::Message)
    expect(subject.message.text).to eq('hello')
  end

  it 'assigns update_id' do
    expect(subject.update_id).to eq(1)
  end

  context 'when webhook is provided' do
    let(:attributes) do
      {
        update_id: 2,
        webhook: { message: { text: 'from webhook' } }
      }
    end

    it 'wraps webhook as Telegram::Types::Webhook' do
      expect(subject.webhook).to be_a(Telegram::Types::Webhook)
      expect(subject.webhook.message).to be_a(Telegram::Types::Message)
      expect(subject.webhook.message.text).to eq('from webhook')
    end
  end
end
