class User < ApplicationRecord
  has_many :downloads, dependent: :destroy, inverse_of: :user
  validates :telegram_user_id, :username, presence: true
  validates :storage_limit_bytes, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  after_initialize :set_defaults, if: :new_record?

  def admin?
    role == 'admin'
  end

  private

  def set_defaults
    self.role ||= 'user'
    self.storage_limit_bytes ||= ENV.fetch('USER_STORAGE_LIMIT_GB', 0).to_i * 1024 * 1024 * 1024
  end
end
