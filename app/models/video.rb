class Video < ApplicationRecord
  scope :min_views, -> { where('views >= 100') }
  scope :min_length, -> { where('duration > 2700') }
  scope :valid_youtube, -> { where.not('youtube_url' => nil)}
end
