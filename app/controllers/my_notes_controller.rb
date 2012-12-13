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
      format.html
      format.json do
        render json:@note
      end
    end
  end
end
