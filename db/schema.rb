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

ActiveRecord::Schema[6.1].define(version: 20120820172904) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "measurements", force: true do |t|
    t.integer  "duration",                           null: false
    t.string   "package",                            null: false
    t.string   "package_version",                    null: false
    t.string   "manufacturer",                       null: false
    t.string   "model",                              null: false
    t.string   "android_version",                    null: false
    t.string   "ruboto_platform_version",            null: false
    t.string   "ruboto_app_version",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "test",                    limit: 32, null: false
    t.string   "compile_mode",            limit: 8
    t.string   "ruby_version",            limit: 8
  end

end
