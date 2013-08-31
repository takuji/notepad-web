class ImagesController < ApplicationController
  before_filter :authenticate_user!

  def create
    logger.info 'ImagesController#create'
    images = params[:file].map do |file|
      image = Image.new
      image.file = file
      image.save
      image
    end
    @images = {files: images.map{|image| image_to_hash(image)}}
    logger.info @images
    render json: @images
  end

  def show
    @image = current_user.images.find params[:id]
    send_file @image.file.current_path, disposition: :inline
  end

private

  def image_to_hash(image)
    file = image.file
    url = image_url image
    {
      name: file.identifier,
      size: file.size,
      url: url,
      thumbnailUrl: url,
      deleteUrl: url,
      deleteType: 'DELETE'
    }
  end
end
