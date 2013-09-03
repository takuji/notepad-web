class AddUseEvernoteToUsers < ActiveRecord::Migration
  def change
    add_column :users, :use_evernote, :boolean, default: false
  end
end
