class EvernoteController < ApplicationController
  before_filter :authenticate_user!

  def new

  end

  def create
    client = EvernoteAccount.oauth_client
    session[:request_token] = client.request_token oauth_callback: auth_callback_evernote_url
    redirect_to session[:request_token].authorize_url
  end

  def show
    unless current_user.use_evernote?
      redirect_to action: :new
    end
  end

  def auth_callback
    unless params[:oauth_verifier] || session[:request_token]
      redirect_to action: :new
    end
    oauth_token = session[:request_token].get_access_token(oauth_verifier: params[:oauth_verifier])
    logger.debug "oauth_token = #{oauth_token}"
    if current_user.create_evernote_account(oauth_token: oauth_token.token)
      redirect_to root_path, notice: t('evernote.messages.authenticated')
    else
      redirect_to root_path, notice: t('evernote.messages.failed_to_authenticate')
    end
  end

end
