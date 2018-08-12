class VideosController < ApplicationController

  # GET /videos
  def index
    @videos = Video.min_views.min_length.valid_youtube.order(reach: :desc)
  end

end
