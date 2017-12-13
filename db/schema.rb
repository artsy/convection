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

ActiveRecord::Schema.define(version: 20171212160509) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assets", force: :cascade do |t|
    t.string  "asset_type"
    t.string  "gemini_token"
    t.jsonb   "image_urls",    default: {}
    t.integer "submission_id"
    t.index ["submission_id"], name: "index_assets_on_submission_id", using: :btree
  end

  create_table "offers", force: :cascade do |t|
    t.integer  "partner_submission_id"
    t.string   "offer_type"
    t.datetime "sale_period_start"
    t.datetime "sale_period_end"
    t.datetime "sale_date"
    t.string   "sale_name"
    t.integer  "low_estimate_cents"
    t.integer  "high_estimate_cents"
    t.string   "currency"
    t.text     "notes"
    t.float    "commission_percent"
    t.integer  "price_cents"
    t.integer  "shipping_cents"
    t.integer  "photography_cents"
    t.integer  "other_fees_cents"
    t.float    "other_fees_percent"
    t.float    "insurance_percent"
    t.integer  "insurance_cents"
    t.string   "state"
    t.string   "created_by_id"
    t.string   "reference_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "submission_id"
    t.index ["partner_submission_id"], name: "index_offers_on_partner_submission_id", using: :btree
    t.index ["reference_id"], name: "index_offers_on_reference_id", using: :btree
    t.index ["submission_id"], name: "index_offers_on_submission_id", using: :btree
  end

  create_table "partner_submissions", force: :cascade do |t|
    t.integer  "submission_id"
    t.integer  "partner_id"
    t.datetime "notified_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["partner_id"], name: "index_partner_submissions_on_partner_id", using: :btree
    t.index ["submission_id"], name: "index_partner_submissions_on_submission_id", using: :btree
  end

  create_table "partners", force: :cascade do |t|
    t.string   "gravity_partner_id", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "name"
    t.index ["gravity_partner_id"], name: "index_partners_on_gravity_partner_id", unique: true, using: :btree
  end

  create_table "submissions", force: :cascade do |t|
    t.string   "user_id"
    t.boolean  "qualified"
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
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "edition"
    t.string   "state"
    t.datetime "receipt_sent_at"
    t.string   "edition_number"
    t.integer  "edition_size"
    t.integer  "reminders_sent_count",     default: 0
    t.datetime "admin_receipt_sent_at"
    t.string   "approved_by"
    t.datetime "approved_at"
    t.string   "rejected_by"
    t.datetime "rejected_at"
    t.integer  "primary_image_id"
    t.index ["primary_image_id"], name: "index_submissions_on_primary_image_id", using: :btree
    t.index ["user_id"], name: "index_submissions_on_user_id", using: :btree
  end

  add_foreign_key "assets", "submissions"
  add_foreign_key "offers", "partner_submissions"
  add_foreign_key "offers", "submissions"
  add_foreign_key "partner_submissions", "partners"
  add_foreign_key "partner_submissions", "submissions"
  add_foreign_key "submissions", "assets", column: "primary_image_id", on_delete: :nullify
end
