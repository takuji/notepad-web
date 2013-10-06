class HomeController < ApplicationController
  def index
    if user_signed_in?
      @notes = current_user.latest_notes.page(params[:page])
      render :dashboard
    end
  end
end
