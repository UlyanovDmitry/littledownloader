class Download < ApplicationRecord
  belongs_to :user

  enum :status, {
    queued: 'queued',
    running: 'running',
    done: 'done',
    failed: 'failed'
  }, default: 'queued'

  validates :url, :chat_id, :status, presence: true
end
