class CreateTranscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :transcriptions do |t|
      t.text :live_client_text
      t.text :server_transcript
      t.text :summary
      t.string :status

      t.timestamps
    end
  end
end
