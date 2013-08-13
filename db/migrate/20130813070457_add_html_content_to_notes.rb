class AddHtmlContentToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :html_content, :text
  end
end
