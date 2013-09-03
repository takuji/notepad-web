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
end
