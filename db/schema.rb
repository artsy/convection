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

ActiveRecord::Schema.define(version: 20170221184930) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assets", force: :cascade do |t|
    t.string  "asset_type"
    t.string  "gemini_token"
    t.string  "image_urls"
    t.integer "submission_id"
    t.index ["submission_id"], name: "index_assets_on_submission_id", using: :btree
  end

  create_table "submissions", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "qualified"
    t.datetime "delivered_at"
    t.string   "artist_id"
    t.string   "title"
    t.string   "medium"
    t.string   "year"
    t.string   "category"
    t.string   "height"
    t.string   "width"
    t.string   "depth"
    t.string   "dimensions_metric"
    t.boolean  "signature"
    t.boolean  "authenticity_certificate"
    t.text     "provenance"
    t.string   "location_city"
    t.string   "location_state"
    t.string   "location_country"
    t.date     "deadline_to_sell"
    t.text     "additional_info"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["user_id"], name: "index_submissions_on_user_id", using: :btree
  end

  add_foreign_key "assets", "submissions"
end
