class AddAudioOnlyToDownloads < ActiveRecord::Migration[8.1]
  def change
    add_column :downloads, :audio_only, :boolean
  end
end
