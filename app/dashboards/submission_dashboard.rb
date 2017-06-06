require "administrate/base_dashboard"

class SubmissionDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    assets: Field::HasMany,
    id: Field::Number,
    user_id: Field::String,
    qualified: Field::Boolean,
    artist_id: Field::String,
    title: Field::String,
    medium: Field::String,
    year: Field::String,
    category: Field::String,
    height: Field::String,
    width: Field::String,
    depth: Field::String,
    dimensions_metric: Field::String,
    signature: Field::Boolean,
    authenticity_certificate: Field::Boolean,
    provenance: Field::Text,
    location_city: Field::String,
    location_state: Field::String,
    location_country: Field::String,
    deadline_to_sell: Field::DateTime,
    additional_info: Field::Text,
    created_at: Field::DateTime,
    edition: Field::Boolean,
    state: Field::String,
    receipt_sent_at: Field::DateTime,
    edition_number: Field::String,
    edition_size: Field::Number,
    reminders_sent_count: Field::Number,
    admin_receipt_sent_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :created_at,
    :user_id,
    :state,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :assets,
    :id,
    :user_id,
    :qualified,
    :artist_id,
    :title,
    :medium,
    :year,
    :category,
    :height,
    :width,
    :depth,
    :dimensions_metric,
    :signature,
    :authenticity_certificate,
    :provenance,
    :location_city,
    :location_state,
    :location_country,
    :deadline_to_sell,
    :additional_info,
    :created_at,
    :edition,
    :state,
    :receipt_sent_at,
    :edition_number,
    :edition_size,
    :reminders_sent_count,
    :admin_receipt_sent_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :assets,
    :user_id,
    :qualified,
    :artist_id,
    :title,
    :medium,
    :year,
    :category,
    :height,
    :width,
    :depth,
    :dimensions_metric,
    :signature,
    :authenticity_certificate,
    :provenance,
    :location_city,
    :location_state,
    :location_country,
    :deadline_to_sell,
    :additional_info,
    :edition,
    :state,
    :edition_number,
    :edition_size,
  ].freeze

  # Overwrite this method to customize how submissions are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(submission)
  #   "Submission ##{submission.id}"
  # end
end
