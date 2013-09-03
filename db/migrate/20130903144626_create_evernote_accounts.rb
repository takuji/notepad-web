class CreateEvernoteAccounts < ActiveRecord::Migration
  def change
    create_table :evernote_accounts do |t|
      t.references :user, index: true
      t.string :oauth_token

      t.timestamps
    end
  end
end
