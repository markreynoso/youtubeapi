
# Populate database with videos from Subsplash API and add data to each model 
# with the use of the YouTube API. 

class SubsplashAPIChallenge
  require 'httparty'
  require 'youtube_video_id'

  # Class constants and secret keys
  ENDPOINT = "https://challenge.subsplash.net"
  # ENV variables may be found in /config/env_vars.yml and initialized in 
  # /config/initializers/env_vars.rb
  HEADERS = {"X-Sap-Auth" => ENV['SUBSPLASH_API_KEY']}
  YOUTUBE_API_KEY = ENV['YOUTUBE_API_KEY']

  # Class instance variable for paginating Subsplash API
  def initialize
    @page = 1
  end
  
  # Call Subsplash API recursively. Can adjust number of pages, or base recursion
  # on number of results. If number of results < 50, do not call - end of data. 
  # Response is sent to compile for every 50 results - this limiter is due to the 
  # YouTube API which will only take a batch request of 50 videos. 
  def callSubsplashAPI
    raw_response = HTTParty.get("#{ENDPOINT}?page[size]=50&fields=title,youtube_url,reach&page[num]=#{@page}", 
      format: :json, 
      :headers => HEADERS)
    case raw_response.code 
      when 200
        compileSubsplashResponse(raw_response) if raw_response.success?
        if @page < 5
          @page += 1
          callSubsplashAPI
        end
      when 404
        puts "Page not found. Code: #{raw_response.code}"
      when 500...600
        puts "An error occured. Code: #{raw_response.code}"
    end
  end

  # Batch is created as a string. Some videos do not contain a valid YouTube
  # ID and will not be sent to the YouTube API. Each video received from the 
  # Subsplash API will be entered into the database. Duration and views will be updated
  # when the YouTube API is called.
  def compileSubsplashResponse(response)
    batch = ''
    response["_embedded"]["media-items"].each do |r|
      youtube_id = extractYouTubeID(r["youtube_url"])
      batch << youtube_id + ',' unless youtube_id == ''
      video = Video.new.tap do |v|
        v.youtube_id = youtube_id
        v.youtube_url = r["youtube_url"]
        v.title = r["title"]
        v.duration = nil
        v.views = nil
        v.reach = r["reach"]
        v.save
      end
    end 
    batch.chop!()
    callYouTubeAPI(batch)
  end

  # YouTube API batch request with up to 50 videos in each request. Response is 
  # sent to compile.
  def callYouTubeAPI(batch_string)
    raw_response = HTTParty.get("https://www.googleapis.com/youtube/v3/videos?key=#{YOUTUBE_API_KEY}&part=contentDetails,statistics&id=#{batch_string}",
      format: :json)
    case raw_response.code 
      when 200
        compileYouTubeResponse(raw_response)
      when 404
        puts "Page not found. Code: #{raw_response.code}"
      when 500...600
        puts "An error occured. Code: #{raw_response.code}"
    end
  end

  # YouTube API response is used to update each video in the datebase with 
  # duration and number views. Duration is saved as a ISO 8601 duration integer, 
  # per YouTube's response format which is stored as total seconds.
  def compileYouTubeResponse(response)
    response["items"].each do |video|
      update = Video.find_by youtube_id: video["id"]
      update.duration = ActiveSupport::Duration.parse(video["contentDetails"]["duration"])
      update.views = video["statistics"]["viewCount"]
      update.save
    end
  end
  
  # Ruby gem used to extract YouTube ID from URL of video. 
  # Returns '' if unable to extract ID. ID is used to call YouTube API
  # which requires an ID to find a single video. 
  def extractYouTubeID(url)
    YoutubeVideoId.extract(url)
  end

end

# Initiate API calls and seed database.
SubsplashAPIChallenge.new.callSubsplashAPI 
