class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def show
    @notes = current_user.latest_notes.page(params[:page])
  end
end
