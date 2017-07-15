class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def update
    # cache - etag ?
    ret = {
      authenticity_token: form_authenticity_token,
      flash: flash.to_hash,
      set: {
        '#special': "<h4>Date: #{Time.now}</h4>"
      }
    }
    render json: ret
  end
end
