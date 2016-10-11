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

ActiveRecord::Schema.define(version: 20161010124126) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chat_users", force: :cascade do |t|
    t.integer  "chat_id",                    null: false
    t.integer  "user_id",                    null: false
    t.boolean  "online",     default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["chat_id", "user_id"], name: "index_chat_users_on_chat_id_and_user_id", unique: true, using: :btree
    t.index ["chat_id"], name: "index_chat_users_on_chat_id", using: :btree
    t.index ["user_id"], name: "index_chat_users_on_user_id", using: :btree
  end

  create_table "chats", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "creator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_chats_on_creator_id", using: :btree
    t.index ["name"], name: "index_chats_on_name", unique: true, using: :btree
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "chat_id",    null: false
    t.integer  "user_id",    null: false
    t.string   "text",       null: false
    t.datetime "created_at"
    t.index ["chat_id"], name: "index_messages_on_chat_id", using: :btree
    t.index ["created_at"], name: "index_messages_on_created_at", using: :btree
    t.index ["user_id"], name: "index_messages_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",             null: false
    t.string   "crypted_password", null: false
    t.string   "salt",             null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["name"], name: "index_users_on_name", unique: true, using: :btree
  end

end
