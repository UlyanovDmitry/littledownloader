class User < ApplicationRecord
  has_many :downloads, dependent: :destroy, inverse_of: :user
  validates :telegram_user_id, :username, presence: true

  def admin?
    role == 'admin'
  end
end
