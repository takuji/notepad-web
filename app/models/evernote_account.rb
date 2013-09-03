class EvernoteAccount < ActiveRecord::Base
  class << self
    def oauth_client
      EvernoteOAuth::Client.new
    end
  end

  belongs_to :user

  after_create do
    user.update_column :use_evernote, true
  end

  after_destroy do
    user.update_column :use_evernote, false
  end

  def notebooks
    note_store.listNotebooks(oauth_token)
  end


private

  def note_store
    @note_store ||= client.note_store
  end

  def client
    p oauth_token
    @client ||= EvernoteOAuth::Client.new(token: oauth_token)
  end
end
