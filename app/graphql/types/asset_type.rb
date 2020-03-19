# frozen_string_literal: true

module Types
  class AssetType < Types::BaseObject
    description 'Submission Asset'

    field :id, ID, 'Uniq ID for this asset', null: false
    field :asset_type, String, 'type of this Asset', null: false
    field :gemini_token, String, 'gemini token for asset', null: true
    field :image_urls, GraphQL::Types::JSON, 'known image urls', null: true
    field :submission_id, ID, null: false
    field :submissionID, ID, null: true # Alias for MPv2 compatability
  end
end
