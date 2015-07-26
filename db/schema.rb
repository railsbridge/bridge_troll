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

ActiveRecord::Schema.define(version: 20150719210256) do

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chapter_leaderships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "chapter_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.string   "name"
    t.integer  "locations_count",       default: 0
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "external_events_count", default: 0
  end

  create_table "chapters_users", id: false, force: :cascade do |t|
    t.integer "chapter_id"
    t.integer "user_id"
  end

  add_index "chapters_users", ["chapter_id", "user_id"], name: "index_chapters_users_on_chapter_id_and_user_id", unique: true

  create_table "dietary_restrictions", force: :cascade do |t|
    t.string   "restriction"
    t.integer  "rsvp_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "event_email_recipients", force: :cascade do |t|
    t.integer  "event_email_id"
    t.integer  "recipient_rsvp_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "event_email_recipients", ["event_email_id"], name: "index_event_email_recipients_on_event_email_id"
  add_index "event_email_recipients", ["recipient_rsvp_id"], name: "index_event_email_recipients_on_recipient_rsvp_id"

  create_table "event_emails", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "sender_id"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "event_emails", ["event_id"], name: "index_event_emails_on_event_id"

  create_table "event_sessions", force: :cascade do |t|
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "event_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "name",                                  null: false
    t.boolean  "required_for_students", default: true
    t.boolean  "volunteers_only",       default: false
  end

  add_index "event_sessions", ["event_id", "name"], name: "index_event_sessions_on_event_id_and_name", unique: true

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "location_id"
    t.text     "details"
    t.string   "time_zone"
    t.integer  "meetup_volunteer_event_id"
    t.integer  "meetup_student_event_id"
    t.text     "volunteer_details"
    t.string   "public_email"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "student_rsvp_limit"
    t.integer  "course_id"
    t.boolean  "allow_student_rsvp",             default: true
    t.boolean  "published",                      default: false
    t.text     "student_details"
    t.boolean  "spam",                           default: false
    t.boolean  "plus_one_host_toggle",           default: true
    t.boolean  "email_on_approval",              default: true
    t.integer  "student_rsvps_count",            default: 0
    t.integer  "student_waitlist_rsvps_count",   default: 0
    t.integer  "volunteer_rsvps_count",          default: 0
    t.datetime "survey_sent_at"
    t.boolean  "has_childcare",                  default: true
    t.boolean  "restrict_operating_systems",     default: false
    t.string   "allowed_operating_system_ids"
    t.boolean  "draft_saved"
    t.integer  "volunteer_rsvp_limit"
    t.integer  "volunteer_waitlist_rsvps_count", default: 0
    t.boolean  "open",                           default: true
  end

  create_table "external_events", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.date     "starts_at"
    t.date     "ends_at"
    t.string   "city"
    t.string   "location"
    t.string   "organizers"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "chapter_id"
  end

  add_index "external_events", ["chapter_id"], name: "index_external_events_on_chapter_id"

  create_table "locations", force: :cascade do |t|
    t.string   "name"
    t.string   "address_1"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.integer  "events_count", default: 0
    t.integer  "chapter_id"
    t.text     "contact_info"
    t.text     "notes"
    t.datetime "archived_at"
  end

  create_table "meetup_users", force: :cascade do |t|
    t.string   "full_name"
    t.integer  "meetup_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "childcaring"
    t.boolean  "writing"
    t.boolean  "designing"
    t.boolean  "mentoring"
    t.boolean  "macosx"
    t.boolean  "windows"
    t.boolean  "linux"
    t.text     "other"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.text     "bio"
    t.boolean  "outreach"
    t.string   "github_username"
  end

  create_table "rsvp_sessions", force: :cascade do |t|
    t.integer  "rsvp_id"
    t.integer  "event_session_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "checked_in",       default: false
    t.datetime "reminded_at"
  end

  create_table "rsvps", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "role_id"
    t.string   "subject_experience",      limit: 250
    t.boolean  "teaching",                            default: false, null: false
    t.boolean  "taing",                               default: false, null: false
    t.integer  "volunteer_assignment_id",             default: 1,     null: false
    t.string   "user_type"
    t.string   "teaching_experience",     limit: 250
    t.text     "childcare_info"
    t.integer  "operating_system_id"
    t.text     "job_details"
    t.integer  "class_level"
    t.integer  "checkins_count",                      default: 0
    t.datetime "reminded_at"
    t.integer  "waitlist_position"
    t.string   "dietary_info"
    t.integer  "section_id"
    t.boolean  "checkiner",                           default: false
    t.text     "plus_one_host"
  end

  add_index "rsvps", ["user_id", "event_id", "user_type"], name: "index_rsvps_on_user_id_and_event_id_and_event_type", unique: true

  create_table "sections", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "class_level"
  end

  add_index "sections", ["event_id"], name: "index_sections_on_event_id"

  create_table "surveys", force: :cascade do |t|
    t.integer  "rsvp_id"
    t.text     "good_things"
    t.text     "bad_things"
    t.text     "other_comments"
    t.integer  "recommendation_likelihood"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
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
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "time_zone"
    t.string   "gender"
    t.boolean  "allow_event_email",      default: true
    t.boolean  "publisher",              default: false
    t.boolean  "spammer",                default: false
    t.integer  "authentications_count",  default: 0
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  add_foreign_key "authentications", "users"
  add_foreign_key "chapter_leaderships", "chapters"
  add_foreign_key "chapter_leaderships", "users"
  add_foreign_key "chapters_users", "chapters"
  add_foreign_key "chapters_users", "users"
  add_foreign_key "dietary_restrictions", "rsvps"
  add_foreign_key "event_email_recipients", "event_emails"
  add_foreign_key "event_email_recipients", "rsvps", column: "recipient_rsvp_id"
  add_foreign_key "event_emails", "events"
  add_foreign_key "event_emails", "users", column: "sender_id"
  add_foreign_key "event_sessions", "events"
  add_foreign_key "events", "locations"
  add_foreign_key "external_events", "chapters"
  add_foreign_key "locations", "chapters"
  add_foreign_key "profiles", "users"
  add_foreign_key "rsvp_sessions", "event_sessions"
  add_foreign_key "rsvp_sessions", "rsvps"
  add_foreign_key "rsvps", "events"
  add_foreign_key "rsvps", "sections"
  add_foreign_key "sections", "events"
  add_foreign_key "surveys", "rsvps"
end
