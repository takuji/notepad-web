class ImagesController < ApplicationController

  def create
    logger.info 'ImagesController#create'
    @images = {
      files: [
        {
          name: 'rails.png',
          size: 6646,
          url: image_url('rails.png'),
          thumbnailUrl: image_url('rails.png'),
          deleteUrl: image_url('rails.png'),
          deleteType: 'DELETE'
        }
      ]
    }
    render json: @images
  end

  def show
    path = Rails.root.join 'public/images/rails.png'
    send_file path
  end
end
