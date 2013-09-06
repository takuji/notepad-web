class AddEvernoteGuidToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :evernote_guid, :string
  end
end
