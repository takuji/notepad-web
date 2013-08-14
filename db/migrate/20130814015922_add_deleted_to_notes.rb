class AddDeletedToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :deleted, :boolean, default: false
  end
end
