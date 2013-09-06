class EvernoteNotebooksController < ApplicationController
  before_filter :prepare_evernote_account

  def index
    @notebooks = @evernote_account.notebooks
  end

private

  def prepare_evernote_account
    @evernote_account = current_user.evernote_account
  end

end
