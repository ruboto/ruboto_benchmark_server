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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120624103132) do

  create_table "measurements", :force => true do |t|
    t.integer  "duration",                              :null => false
    t.string   "package",                               :null => false
    t.string   "package_version",                       :null => false
    t.string   "manufacturer",                          :null => false
    t.string   "model",                                 :null => false
    t.string   "android_version",                       :null => false
    t.string   "ruboto_platform_version",               :null => false
    t.string   "ruboto_app_version",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "test",                    :limit => 32, :null => false
  end

end
