class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :validatable
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :omniauthable

  class << self
    def find_for_twitter_oauth(auth, signed_in_resource=nil)
      user = User.where(:provider => auth.provider, :uid => auth.uid).first
      if user
        user.image = auth.info.image
        user.save
      else
        user = User.create(name: auth.extra.raw_info.name,
                           provider: auth.provider,
                           uid: auth.uid,
                           email: auth.info.email || '',
                           password: Devise.friendly_token[0,20],
                           image: auth.info.image)
      end
      user
    end
  end

  has_many :notes
  has_many :images
  has_one :evernote_account
  has_many :groups

  def latest_notes
    notes.active.order('updated_at DESC')
  end

  def deleted_notes
    notes.deleted.order('updated_at DESC')
  end
end
