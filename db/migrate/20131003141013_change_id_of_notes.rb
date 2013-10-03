class ChangeIdOfNotes < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE notes CHANGE COLUMN id id BIGINT NOT NULL AUTO_INCREMENT'
  end

  def down
    execute 'ALTER TABLE notes CHANGE COLUMN id id INT(11) NOT NULL AUTO_INCREMENT'
  end
end
