class AddDeletedAtToDownloads < ActiveRecord::Migration[8.1]
  def change
    add_column :downloads, :deleted_at, :datetime
    add_index :downloads, :deleted_at
  end
end
