class AddNotebookNameToEvernoteAccounts < ActiveRecord::Migration
  def change
    add_column :evernote_accounts, :notebook_name, :string, default: 'Notepad'
  end
end
