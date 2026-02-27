class AddStorageLimitBytesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :storage_limit_bytes, :bigint
  end
end
