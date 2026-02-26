class CreateDownloads < ActiveRecord::Migration[8.1]
  def change
    create_table :downloads, id: :uuid do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.bigint :chat_id, null: false
      t.text :url, null: false
      t.string :status, null: false, default: 'queued'
      t.text :error, null: false, default: ''
      t.text :output_path, null: false, default: ''
      t.timestamps
    end
    add_index :downloads, :chat_id
    add_index :downloads, :status
    add_index :downloads, :created_at
  end
end
