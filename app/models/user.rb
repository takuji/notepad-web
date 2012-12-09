class User < ActiveRecord::Base
  attr_accessible :email, :image, :name, :provider, :secret, :token, :uid

  def self.find_or_create_from_auth_hash(auth_hash)
    User.find_by_uid(auth_hash["uid"]) || User.create! do |user|
      user.provider = auth_hash["provider"]
      user.uid = auth_hash["uid"]
      user.name = auth_hash["info"]["name"]
      user.email = auth_hash["info"]["email"]
      user.image = auth_hash["info"]["image"]
      user.token = auth_hash["credentials"]["token"]
      user.secret = auth_hash["credentials"]["secret"]
    end
  end
end
