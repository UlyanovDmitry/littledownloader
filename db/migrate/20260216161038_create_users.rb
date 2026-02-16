class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.bigint :telegram_user_id
      t.text :username
      t.text :first_name
      t.text :last_name
      t.boolean :allowed
      t.text :role

      t.timestamps
    end
  end
end
