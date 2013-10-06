class CreateGroupNotes < ActiveRecord::Migration
  def change
    create_table :group_notes do |t|
      t.integer :group_id
      t.integer :note_id, limit: 8

      t.timestamps
    end

    add_index :group_notes, :group_id
    add_index :group_notes, :note_id
  end
end
