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

ActiveRecord::Schema.define(version: 20150325090549) do

  create_table "advise_reports", force: :cascade do |t|
    t.string  "appname",     limit: 255
    t.integer "advise",      limit: 4
    t.integer "quota",       limit: 4
    t.integer "usage",       limit: 4
    t.string  "report_type", limit: 255
  end

  create_table "resources_data", force: :cascade do |t|
    t.string   "appname",    limit: 255
    t.float    "cpu",        limit: 24
    t.integer  "disk",       limit: 4
    t.integer  "memory",     limit: 4
    t.integer  "perm",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscribes", force: :cascade do |t|
    t.string   "appname",      limit: 255
    t.boolean  "cpu",          limit: 1
    t.float    "cpu_quota",    limit: 24
    t.boolean  "disk",         limit: 1
    t.integer  "disk_quota",   limit: 4
    t.boolean  "memory",       limit: 1
    t.integer  "memory_quota", limit: 4
    t.boolean  "perm",         limit: 1
    t.integer  "perm_quota",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
