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

ActiveRecord::Schema.define(:version => 20111019070502) do

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

  create_table "registrations", :force => true do |t|
    t.integer  "event_id",                                  :null => false
    t.boolean  "waitlisted",             :default => false
    t.datetime "withdrawn_at"
    t.string   "registrant_name",                           :null => false
    t.string   "registrant_email",                          :null => false
    t.string   "registrant_description"
    t.integer  "inviter_id"
    t.integer  "class_level",            :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "registrations", ["event_id"], :name => "index_registrations_on_event_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tshirt_coupons", :force => true do |t|
    t.integer  "user_id",            :null => false
    t.boolean  "skill_teaching"
    t.boolean  "skill_taing"
    t.boolean  "skill_coordinating"
    t.boolean  "skill_mentoring"
    t.boolean  "skill_hacking"
    t.boolean  "skill_designing"
    t.boolean  "skill_writing"
    t.boolean  "skill_evangelizing"
    t.boolean  "skill_childcaring"
    t.string   "skill_other"
    t.string   "tshirt_size",        :null => false
    t.datetime "received_shirt_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tshirt_coupons", ["user_id"], :name => "index_tshirt_coupons_on_user_id", :unique => true

  create_table "user_roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "name",                                                     :null => false
    t.boolean  "admin",                                 :default => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
