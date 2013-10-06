class GroupNote < ActiveRecord::Base
  belongs_to :group
  belongs_to :note
end
