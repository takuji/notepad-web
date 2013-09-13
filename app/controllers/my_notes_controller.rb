class MyNotesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @notes = current_user.latest_notes.select(:id, :title, :created_at).page(params[:page])
    respond_to do |format|
      format.html
      format.json do
        render json:@notes.as_json(:methods => :title)
      end
    end
  end

  def search
    if params[:q]
      @notes = Note.search params[:q], page: params[:page] || 1
    end
  end

  def deleted
    @notes = current_user.latest_notes.deleted.select(:id, :title).page(params[:page])
    respond_to do |format|
      format.html
      format.json do
        render json:@notes.as_json(:methods => :title)
      end
    end
  end

  def create
    @note = Note.create!(user: current_user)
    redirect_to action: :edit, id:@note
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
    render layout: false
  end

  def html_content
    @note = current_user.notes.find(params[:id])
    render layout: false
  end

  def edit
    @note = current_user.notes.find(params[:id])
    respond_to do |format|
      format.html do
        render layout: 'note'
      end
      format.json do
        render json:@note
      end
    end
  end

  def update
    @note = current_user.notes.find(params[:id])
    if @note.update_attributes(content: params[:content], html_content: params[:html_content])
      render json:@note
    else
      render json:@note, :status => :unprocessable_entity
    end
  end

  def delete
    @note = current_user.notes.find(params[:id])
    if @note.move_to_trash
      head :ok
    else
      head :unprocessable_entity
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
