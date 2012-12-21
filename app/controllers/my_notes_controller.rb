class MyNotesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @notes = current_user.latest_notes.page(params[:page])
    respond_to do |format|
      format.html
      format.json do
        render json:@notes.as_json(:methods => :title)
      end
    end
  end

  def create
    @note = Note.create!(user:current_user)
    redirect_to action:"show", id:@note
  end

  def show
    @note = current_user.notes.find(params[:id])
    respond_to do |format|
      format.html do
        render layout:"note"
      end
      format.json do
        render json:@note
      end
    end
  end

  def content
    @note = current_user.notes.find(params[:id])
    render layout:false
  end

  def update
    @note = current_user.notes.find(params[:id])
    if @note.update_attributes(content:params[:content])
      render json:@note
    else
      render json:@note, :status => :unprocessable_entity
    end
  end

  def destroy
    @note = current_user.notes.find(params[:id])
    if @note
      @note.destroy
    end
    head :ok
  end
end
