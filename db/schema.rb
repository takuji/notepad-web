# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131003150916) do

  create_table "evernote_accounts", force: true do |t|
    t.integer  "user_id"
    t.string   "oauth_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "notebook_name", default: "Notepad"
  end

  add_index "evernote_accounts", ["user_id"], name: "index_evernote_accounts_on_user_id", using: :btree

  create_table "group_notes", force: true do |t|
    t.integer  "group_id"
    t.integer  "note_id",    limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_notes", ["group_id"], name: "index_group_notes_on_group_id", using: :btree
  add_index "group_notes", ["note_id"], name: "index_group_notes_on_note_id", using: :btree

  create_table "groups", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["user_id"], name: "index_groups_on_user_id", using: :btree

  create_table "images", force: true do |t|
    t.string   "file"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "images", ["user_id"], name: "index_images_on_user_id", using: :btree

  create_table "notes", force: true do |t|
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.text     "html_content"
    t.string   "title"
    t.boolean  "deleted",       default: false
    t.string   "evernote_guid"
  end

  add_index "notes", ["user_id"], name: "index_notes_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "use_evernote",           default: false
    t.string   "image"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
