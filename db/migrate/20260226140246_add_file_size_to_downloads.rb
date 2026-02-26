class AddFileSizeToDownloads < ActiveRecord::Migration[8.1]
  def change
    add_column :downloads, :file_size, :bigint
  end
end
