class User < ApplicationRecord
  validates :telegram_user_id, :username, presence: true
end
