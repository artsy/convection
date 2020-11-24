# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_20_231224) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'pg_trgm'
  enable_extension 'plpgsql'
  enable_extension 'unaccent'

  create_table 'artist_standing_scores', force: :cascade do |t|
    t.string 'artist_id'
    t.float 'artist_score'
    t.float 'auction_score'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'assets', id: :serial, force: :cascade do |t|
    t.string 'asset_type'
    t.string 'gemini_token'
    t.jsonb 'image_urls', default: {}
    t.integer 'submission_id'
    t.index %w[submission_id], name: 'index_assets_on_submission_id'
  end

  create_table 'notes', force: :cascade do |t|
    t.string 'gravity_user_id', null: false
    t.text 'body', null: false
    t.bigint 'submission_id'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index %w[submission_id], name: 'index_notes_on_submission_id'
  end

  create_table 'offer_responses', force: :cascade do |t|
    t.bigint 'offer_id'
    t.string 'intended_state', null: false
    t.string 'phone_number'
    t.text 'comments'
    t.string 'rejection_reason'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index %w[offer_id], name: 'index_offer_responses_on_offer_id'
  end

  create_table 'offers', id: :serial, force: :cascade do |t|
    t.integer 'partner_submission_id'
    t.string 'offer_type'
    t.datetime 'sale_period_start'
    t.datetime 'sale_period_end'
    t.datetime 'sale_date'
    t.string 'sale_name'
    t.bigint 'low_estimate_cents'
    t.bigint 'high_estimate_cents'
    t.string 'currency'
    t.text 'notes'
    t.float 'commission_percent'
    t.bigint 'price_cents'
    t.string 'shipping_info'
    t.string 'photography_info'
    t.string 'other_fees_info'
    t.string 'insurance_info'
    t.string 'state'
    t.string 'created_by_id'
    t.string 'reference_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'submission_id'
    t.datetime 'sent_at'
    t.string 'sent_by'
    t.string 'rejection_reason'
    t.text 'rejection_note'
    t.string 'rejected_by'
    t.datetime 'rejected_at'
    t.datetime 'review_started_at'
    t.datetime 'consigned_at'
    t.string 'override_email'
    t.text 'partner_info'
    t.string 'deadline_to_consign'
    t.string 'sale_location'
    t.integer 'offer_responses_count'
    t.index %w[partner_submission_id],
            name: 'index_offers_on_partner_submission_id'
    t.index %w[reference_id], name: 'index_offers_on_reference_id'
    t.index %w[submission_id], name: 'index_offers_on_submission_id'
  end

  create_table 'partner_submissions', id: :serial, force: :cascade do |t|
    t.integer 'submission_id'
    t.integer 'partner_id'
    t.datetime 'notified_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'accepted_offer_id'
    t.float 'partner_commission_percent'
    t.float 'artsy_commission_percent'
    t.string 'sale_name'
    t.string 'sale_location'
    t.string 'sale_lot_number'
    t.datetime 'sale_date'
    t.bigint 'sale_price_cents'
    t.string 'currency'
    t.datetime 'partner_invoiced_at'
    t.datetime 'partner_paid_at'
    t.text 'notes'
    t.string 'state'
    t.string 'reference_id'
    t.text 'canceled_reason'
    t.index %w[accepted_offer_id],
            name: 'index_partner_submissions_on_accepted_offer_id'
    t.index %w[partner_id], name: 'index_partner_submissions_on_partner_id'
    t.index %w[submission_id],
            name: 'index_partner_submissions_on_submission_id'
  end

  create_table 'partners', id: :serial, force: :cascade do |t|
    t.string 'gravity_partner_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'name'
    t.index %w[gravity_partner_id],
            name: 'index_partners_on_gravity_partner_id', unique: true
  end

  create_table 'submissions', id: :serial, force: :cascade do |t|
    t.string 'ext_user_id'
    t.boolean 'qualified'
    t.string 'artist_id'
    t.string 'title'
    t.string 'medium'
    t.string 'year'
    t.string 'category'
    t.string 'height'
    t.string 'width'
    t.string 'depth'
    t.string 'dimensions_metric'
    t.boolean 'signature'
    t.boolean 'authenticity_certificate'
    t.text 'provenance'
    t.string 'location_city'
    t.string 'location_state'
    t.string 'location_country'
    t.date 'deadline_to_sell'
    t.text 'additional_info'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.boolean 'edition'
    t.string 'state'
    t.datetime 'receipt_sent_at'
    t.string 'edition_number'
    t.integer 'edition_size'
    t.integer 'reminders_sent_count', default: 0
    t.datetime 'admin_receipt_sent_at'
    t.string 'approved_by'
    t.datetime 'approved_at'
    t.string 'rejected_by'
    t.datetime 'rejected_at'
    t.integer 'primary_image_id'
    t.integer 'consigned_partner_submission_id'
    t.string 'user_email'
    t.integer 'offers_count', default: 0
    t.integer 'user_id'
    t.bigint 'minimum_price_cents'
    t.string 'currency'
    t.string 'user_agent'
    t.datetime 'deleted_at'
    t.float 'artist_score'
    t.float 'auction_score'
    t.string 'assigned_to'
    t.datetime 'published_at'
    t.string 'source_artwork_id'
    t.index %w[consigned_partner_submission_id],
            name: 'index_submissions_on_consigned_partner_submission_id'
    t.index %w[ext_user_id], name: 'index_submissions_on_ext_user_id'
    t.index %w[primary_image_id], name: 'index_submissions_on_primary_image_id'
    t.index %w[user_id], name: 'index_submissions_on_user_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'gravity_user_id', null: false
    t.string 'email'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[gravity_user_id],
            name: 'index_users_on_gravity_user_id', unique: true
  end

  add_foreign_key 'assets', 'submissions'
  add_foreign_key 'notes', 'submissions'
  add_foreign_key 'offer_responses', 'offers'
  add_foreign_key 'offers', 'partner_submissions', on_delete: :cascade
  add_foreign_key 'offers', 'submissions', on_delete: :cascade
  add_foreign_key 'partner_submissions',
                  'offers',
                  column: 'accepted_offer_id', on_delete: :nullify
  add_foreign_key 'partner_submissions', 'partners'
  add_foreign_key 'partner_submissions', 'submissions'
  add_foreign_key 'submissions',
                  'assets',
                  column: 'primary_image_id', on_delete: :nullify
  add_foreign_key 'submissions',
                  'partner_submissions',
                  column: 'consigned_partner_submission_id', on_delete: :nullify
  add_foreign_key 'submissions', 'users'
end
