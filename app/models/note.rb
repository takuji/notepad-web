class Note < ActiveRecord::Base
  belongs_to :user

  before_save :update_title
  
  private
  
  def update_title
    self.title = extract_title
  end

  def extract_title
    content ? content.split("\n", 2)[0] : "Untitiled"
  end
end
