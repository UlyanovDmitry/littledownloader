class ChangeAudioOnlyDefaultOnDownloads < ActiveRecord::Migration[8.1]
  def change
    change_column_default :downloads, :audio_only, from: nil, to: false
  end
end
