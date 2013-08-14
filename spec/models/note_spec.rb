require 'spec_helper'

describe Note do
  subject {FactoryGirl.create(:note)}

  describe 'move_to_trash' do
    it 'moves the note to the trash' do
      subject.move_to_trash
      subject.should be_deleted
    end
  end
end
