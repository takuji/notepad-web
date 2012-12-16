class MyNotesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @notes = current_user.notes.page(params[:page])
  end

  def create
    @note = Note.create!(user:current_user)
    redirect_to action:"show", id:@note
  end

  def show
    @note = Note.find(params[:id])
    respond_to do |format|
      format.html do
        render layout:"note"
      end
      format.json do
        render json:@note
      end
    end
  end

  def update
    @note = current_user.notes.find(params[:id])
    if @note.update_attributes(content:params[:content])
      render json:@note
    else
      render json:@note, :status => :unprocessable_entity
    end
  end
end
