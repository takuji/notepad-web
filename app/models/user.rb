class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :validatable
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :omniauthable

  class << self
    def find_for_twitter_oauth(auth, signed_in_resource=nil)
      p auth
      p auth.provider
      p auth.uid

      user = User.where(:provider => auth.provider, :uid => auth.uid).first
      unless user
        user = User.create(name:auth.extra.raw_info.name,
                           provider:auth.provider,
                           uid:auth.uid,
                           email:auth.info.email || "",
                           password:Devise.friendly_token[0,20]
        )
      end
      user
    end
  end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :uid, :provider, :name

  has_many :notes

  def latest_notes
    notes.order("updated_at DESC")
  end
end
