class Note < ActiveRecord::Base
  belongs_to :user
  attr_accessible :content, :user

  def title
    content.split("\n", 2)[0]
  end
end
