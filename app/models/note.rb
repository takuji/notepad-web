class Note < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  scope :active, ->{ where(deleted: false) }
  scope :deleted, ->{ where(deleted: true) }

  belongs_to :user
  has_many :group_note
  has_many :groups, through: :group_note, uniq: true

  before_save :update_title

  def move_to_trash
    update_attribute :deleted, true
  end

  def move_to_inbox
    update_attribute :deleted, false
  end

  private
  
  def update_title
    self.title = extract_title
  end

  def extract_title
    content ? strip_index_marking(content.split("\n", 2)[0]) : "Untitiled"
  end

  def strip_index_marking(s)
    s.sub(/\A#+\s*/, '')
  end
end
