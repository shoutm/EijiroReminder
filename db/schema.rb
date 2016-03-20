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

ActiveRecord::Schema.define(version: 20160319143742) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "er_items", force: true do |t|
    t.integer  "e_id",                       null: false
    t.string   "name",                       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disabled",   default: false
  end

  create_table "er_items_users", force: true do |t|
    t.integer  "user_id",      null: false
    t.integer  "item_id",      null: false
    t.string   "wordbook_url", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "er_items_users", ["item_id"], name: "index_er_items_users_on_item_id", using: :btree
  add_index "er_items_users", ["user_id"], name: "index_er_items_users_on_user_id", using: :btree

  create_table "er_items_users_tags", force: true do |t|
    t.integer  "items_user_id",     null: false
    t.integer  "tag_id",            null: false
    t.datetime "registration_date", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "er_items_users_tags", ["items_user_id"], name: "index_er_items_users_tags_on_items_user_id", using: :btree
  add_index "er_items_users_tags", ["tag_id"], name: "index_er_items_users_tags_on_tag_id", using: :btree

  create_table "er_tags", force: true do |t|
    t.string   "name",       null: false
    t.string   "tag",        null: false
    t.integer  "interval",   null: false
    t.integer  "order",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "er_tags", ["order"], name: "index_er_tags_on_order", unique: true, using: :btree

  create_table "er_users", force: true do |t|
    t.string   "name",       null: false
    t.string   "email",      null: false
    t.string   "password",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "er_items_users", "er_items", name: "er_items_users_item_id_fk", column: "item_id"
  add_foreign_key "er_items_users", "er_users", name: "er_items_users_user_id_fk", column: "user_id"

  add_foreign_key "er_items_users_tags", "er_items_users", name: "er_items_users_tags_items_user_id_fk", column: "items_user_id"
  add_foreign_key "er_items_users_tags", "er_tags", name: "er_items_users_tags_tag_id_fk", column: "tag_id"

end
