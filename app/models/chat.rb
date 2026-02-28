# frozen_string_literal: true

class Chat < ApplicationRecord
  validates :telegram_chat_id, presence: true, uniqueness: true

  has_many :downloads, dependent: :destroy, inverse_of: :chat

  def private?
    chat_type == 'private'
  end
end
