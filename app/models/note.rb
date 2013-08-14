class Note < ActiveRecord::Base
  scope :active, ->{ where(deleted: false) }

  belongs_to :user

  before_save :update_title

  def move_to_trash
    update_attribute :deleted, true
  end
  
  private
  
  def update_title
    self.title = extract_title
  end

  def extract_title
    content ? content.split("\n", 2)[0] : "Untitiled"
  end
end
