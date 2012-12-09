class SessionsController < ApplicationController

  def new
    redirect_to "/auth/twitter"
  end

  def create
    @user = User.find_or_create_from_auth_hash(auth_hash)
    session[:uid] = @user.uid
    redirect_to root_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
