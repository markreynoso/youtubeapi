class CreateVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :videos do |t|
      t.text :title
      t.text :youtube_url
      t.integer :reach
      t.string :duration
      t.bigserial :views
      t.string :youtube_id

      t.timestamps
    end
  end
end
