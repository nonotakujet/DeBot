class TestController < ApplicationController
  def callback
    render :json => {success: true}
  end
end
