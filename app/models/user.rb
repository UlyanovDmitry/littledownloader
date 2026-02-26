class User < ApplicationRecord
  has_many :downloads, dependent: :destroy
  validates :telegram_user_id, :username, presence: true
end
