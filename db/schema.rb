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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130324053250) do

  create_table "event_sessions", :force => true do |t|
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "event_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "name",       :null => false
  end

  add_index "event_sessions", ["event_id", "name"], :name => "index_event_sessions_on_event_id_and_name", :unique => true

  create_table "events", :force => true do |t|
    t.string   "title"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "location_id"
    t.text     "details"
    t.string   "time_zone"
    t.integer  "meetup_volunteer_event_id"
    t.integer  "meetup_student_event_id"
    t.text     "volunteer_details"
    t.string   "public_email"
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.string   "address_1"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
  end

  create_table "meetup_users", :force => true do |t|
    t.string   "full_name"
    t.integer  "meetup_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "childcaring"
    t.boolean  "writing"
    t.boolean  "designing"
    t.boolean  "mentoring"
    t.boolean  "macosx"
    t.boolean  "windows"
    t.boolean  "linux"
    t.text     "other"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "bio"
    t.boolean  "outreach"
  end

  create_table "rsvp_sessions", :force => true do |t|
    t.integer  "rsvp_id"
    t.integer  "event_session_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "checked_in",       :default => false
  end

  create_table "rsvps", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.integer  "role_id"
    t.string   "subject_experience",      :limit => 250
    t.boolean  "teaching",                               :default => false, :null => false
    t.boolean  "taing",                                  :default => false, :null => false
    t.integer  "volunteer_assignment_id",                :default => 1,     :null => false
    t.string   "user_type"
    t.string   "teaching_experience",     :limit => 250
    t.text     "childcare_info"
  end

  add_index "rsvps", ["user_id", "event_id", "user_type"], :name => "index_rsvps_on_user_id_and_event_id_and_event_type", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "admin",                  :default => false
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "meetup_id"
    t.string   "time_zone"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
