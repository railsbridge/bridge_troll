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

ActiveRecord::Schema.define(:version => 20110324060633) do

  create_table "events", :force => true do |t|
    t.string   "name",                           :null => false
    t.integer  "location_id",                    :null => false
    t.datetime "start_time",                     :null => false
    t.datetime "end_time",                       :null => false
    t.text     "description"
    t.integer  "capacity",        :default => 1, :null => false
    t.integer  "guests_per_user", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["location_id"], :name => "index_events_on_location_id"

  create_table "locations", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
