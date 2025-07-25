# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2020_03_29_093106) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "unaccent"

  create_table "authentications", force: :cascade do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["uid", "provider"], name: "index_authentications_on_uid_and_provider", unique: true
  end

  create_table "chapter_leaderships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "chapter_id"
    t.index ["chapter_id", "user_id"], name: "index_chapter_leaderships_on_chapter_id_and_user_id", unique: true
  end

  create_table "chapters", force: :cascade do |t|
    t.string "name"
    t.integer "events_count", default: 0
    t.integer "external_events_count", default: 0
    t.integer "organization_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_chapters_on_name", unique: true
  end

  create_table "courses", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "dietary_restrictions", force: :cascade do |t|
    t.string "restriction"
    t.integer "rsvp_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["rsvp_id", "restriction"], name: "index_dietary_restrictions_on_rsvp_id_and_restriction", unique: true
  end

  create_table "event_email_recipients", force: :cascade do |t|
    t.integer "event_email_id"
    t.integer "recipient_rsvp_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["event_email_id"], name: "index_event_email_recipients_on_event_email_id"
    t.index ["recipient_rsvp_id"], name: "index_event_email_recipients_on_recipient_rsvp_id"
  end

  create_table "event_emails", force: :cascade do |t|
    t.integer "event_id"
    t.integer "sender_id"
    t.string "subject"
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["event_id"], name: "index_event_emails_on_event_id"
  end

  create_table "event_sessions", force: :cascade do |t|
    t.datetime "starts_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.integer "event_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name", null: false
    t.boolean "required_for_students", default: true
    t.boolean "volunteers_only", default: false
    t.integer "location_id"
    t.index ["event_id", "name"], name: "index_event_sessions_on_event_id_and_name", unique: true
    t.index ["location_id"], name: "index_event_sessions_on_location_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "location_id"
    t.text "details"
    t.string "time_zone"
    t.text "volunteer_details"
    t.string "public_email"
    t.datetime "starts_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.integer "student_rsvp_limit"
    t.integer "course_id"
    t.boolean "allow_student_rsvp", default: true
    t.text "student_details"
    t.boolean "spam", default: false
    t.boolean "plus_one_host_toggle", default: true
    t.boolean "email_on_approval", default: true
    t.integer "student_rsvps_count", default: 0
    t.integer "student_waitlist_rsvps_count", default: 0
    t.integer "volunteer_rsvps_count", default: 0
    t.datetime "survey_sent_at", precision: nil
    t.boolean "has_childcare", default: true
    t.boolean "restrict_operating_systems", default: false
    t.string "allowed_operating_system_ids"
    t.integer "volunteer_rsvp_limit"
    t.integer "volunteer_waitlist_rsvps_count", default: 0
    t.string "target_audience"
    t.boolean "open", default: true
    t.text "survey_greeting"
    t.datetime "announcement_email_sent_at", precision: nil
    t.integer "current_state", default: 0
    t.string "imported_event_data"
    t.integer "chapter_id", null: false
    t.boolean "food_provided", default: true, null: false
    t.text "custom_question"
    t.index ["chapter_id"], name: "index_events_on_chapter_id"
  end

  create_table "external_events", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.date "starts_at"
    t.date "ends_at"
    t.string "city"
    t.string "location"
    t.string "organizers"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "region_id"
    t.integer "chapter_id"
    t.index ["chapter_id"], name: "index_external_events_on_chapter_id"
    t.index ["region_id"], name: "index_external_events_on_region_id"
  end

  create_table "levels", force: :cascade do |t|
    t.integer "course_id"
    t.integer "num"
    t.string "color"
    t.string "title"
    t.text "level_description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["course_id"], name: "index_levels_on_course_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.string "address_1"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.float "latitude"
    t.float "longitude"
    t.boolean "gmaps"
    t.integer "events_count", default: 0
    t.integer "region_id"
    t.text "contact_info"
    t.text "notes"
    t.datetime "archived_at", precision: nil
  end

  create_table "meetup_users", force: :cascade do |t|
    t.string "full_name"
    t.integer "meetup_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "organization_leaderships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "organization_id"
    t.index ["organization_id", "user_id"], name: "index_organization_leaderships_on_organization_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_organization_leaderships_on_user_id"
  end

  create_table "organization_subscriptions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "organization_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "code_of_conduct_url"
  end

  create_table "profiles", force: :cascade do |t|
    t.integer "user_id"
    t.boolean "childcaring"
    t.boolean "writing"
    t.boolean "designing"
    t.boolean "mentoring"
    t.boolean "macosx"
    t.boolean "windows"
    t.boolean "linux"
    t.text "other"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "bio"
    t.boolean "outreach"
    t.string "github_username"
    t.string "twitter_username"
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "region_leaderships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "region_id"
    t.index ["region_id", "user_id"], name: "index_region_leaderships_on_region_id_and_user_id", unique: true
  end

  create_table "regions", force: :cascade do |t|
    t.string "name"
    t.integer "locations_count", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "external_events_count", default: 0
    t.index ["name"], name: "index_regions_on_name", unique: true
  end

  create_table "regions_users", force: :cascade do |t|
    t.integer "region_id"
    t.integer "user_id"
    t.index ["region_id", "user_id"], name: "index_regions_users_on_region_id_and_user_id", unique: true
  end

  create_table "rsvp_sessions", force: :cascade do |t|
    t.integer "rsvp_id"
    t.integer "event_session_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "checked_in", default: false
    t.datetime "reminded_at", precision: nil
    t.index ["event_session_id", "rsvp_id"], name: "index_rsvp_sessions_on_event_session_id_and_rsvp_id", unique: true
  end

  create_table "rsvps", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "role_id"
    t.string "subject_experience", limit: 250
    t.boolean "teaching", default: false, null: false
    t.boolean "taing", default: false, null: false
    t.integer "volunteer_assignment_id", default: 1, null: false
    t.string "user_type"
    t.string "teaching_experience", limit: 250
    t.text "childcare_info"
    t.integer "operating_system_id"
    t.text "job_details"
    t.integer "class_level"
    t.integer "checkins_count", default: 0
    t.datetime "reminded_at", precision: nil
    t.integer "waitlist_position"
    t.string "dietary_info"
    t.integer "section_id"
    t.boolean "checkiner", default: false
    t.text "plus_one_host"
    t.string "token"
    t.text "custom_question_answer"
    t.index ["token"], name: "index_rsvps_on_token", unique: true
    t.index ["user_id", "event_id", "user_type"], name: "index_rsvps_on_user_id_and_event_id_and_event_type", unique: true
  end

  create_table "sections", force: :cascade do |t|
    t.integer "event_id"
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "class_level"
    t.index ["event_id"], name: "index_sections_on_event_id"
  end

  create_table "surveys", force: :cascade do |t|
    t.integer "rsvp_id"
    t.text "good_things"
    t.text "bad_things"
    t.text "other_comments"
    t.integer "recommendation_likelihood"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "appropriate_for_skill"
    t.index ["rsvp_id"], name: "index_surveys_on_rsvp_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "admin", default: false
    t.string "first_name"
    t.string "last_name"
    t.string "time_zone"
    t.string "gender"
    t.boolean "allow_event_email", default: true
    t.boolean "publisher", default: false
    t.boolean "spammer", default: false
    t.integer "authentications_count", default: 0
    t.boolean "external_event_editor", default: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "authentications", "users"
  add_foreign_key "chapter_leaderships", "chapters"
  add_foreign_key "chapter_leaderships", "users"
  add_foreign_key "chapters", "organizations"
  add_foreign_key "dietary_restrictions", "rsvps"
  add_foreign_key "event_email_recipients", "event_emails"
  add_foreign_key "event_email_recipients", "rsvps", column: "recipient_rsvp_id"
  add_foreign_key "event_emails", "events"
  add_foreign_key "event_emails", "users", column: "sender_id"
  add_foreign_key "event_sessions", "events"
  add_foreign_key "event_sessions", "locations"
  add_foreign_key "events", "chapters"
  add_foreign_key "events", "locations"
  add_foreign_key "external_events", "chapters"
  add_foreign_key "external_events", "regions"
  add_foreign_key "locations", "regions"
  add_foreign_key "organization_leaderships", "organizations"
  add_foreign_key "organization_leaderships", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "region_leaderships", "regions"
  add_foreign_key "region_leaderships", "users"
  add_foreign_key "regions_users", "regions"
  add_foreign_key "regions_users", "users"
  add_foreign_key "rsvp_sessions", "event_sessions"
  add_foreign_key "rsvp_sessions", "rsvps"
  add_foreign_key "rsvps", "events"
  add_foreign_key "rsvps", "sections"
  add_foreign_key "sections", "events"
  add_foreign_key "surveys", "rsvps"
end
