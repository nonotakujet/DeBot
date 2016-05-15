class TestController < ApplicationController
  def callback
    search_word = "白崎"
    google_custom_api = DeBot::GoogleCustomApi.new
    image_url, preview_url = google_custom_api.search_image(search_word)
    render :json => {
      image_url: image_url,
      preview_url: preview_url
    }
  end
end
