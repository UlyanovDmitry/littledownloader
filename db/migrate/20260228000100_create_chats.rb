# frozen_string_literal: true

class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
      t.bigint :telegram_chat_id, null: false
      t.string :chat_type
      t.text :username
      t.text :title
      t.text :first_name
      t.text :last_name
      t.boolean :with_admins, default: false

      t.timestamps
    end

    add_index :chats, :telegram_chat_id, unique: true
  end
end
