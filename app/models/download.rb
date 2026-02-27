class Download < ApplicationRecord
  acts_as_paranoid

  belongs_to :user, inverse_of: :downloads

  default_scope { where(deleted_at: nil) }

  enum :status, {
    queued: 'queued',
    running: 'running',
    done: 'done',
    failed: 'failed'
  }, default: 'queued'

  validates :url, :chat_id, :status, presence: true
  validates :audio_only, inclusion: { in: [true, false] }
end
