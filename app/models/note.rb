class Note < ActiveRecord::Base
  belongs_to :user
  attr_accessible :content, :user

  def title
    content ? content.split("\n", 2)[0] : "Untitiled"
  end
end
