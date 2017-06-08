require 'administrate/base_dashboard'

class AssetDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    submission: Field::BelongsTo,
    id: Field::Number,
    asset_type: Field::String,
    image_urls: Field::String.with_options(searchable: false)
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :submission,
    :id,
    :asset_type
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :submission,
    :id,
    :asset_type,
    :image_urls
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :submission,
    :asset_type,
    :image_urls
  ].freeze

  # Overwrite this method to customize how assets are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(asset)
  #   "Asset ##{asset.id}"
  # end
end
