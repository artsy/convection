# frozen_string_literal: true

module Types
  AssetType =
    GraphQL::ObjectType.define do
      name 'Asset'
      description 'Submission Asset'

      field :id, !types.ID, 'Uniq ID for this asset'
      field :asset_type, !types.String, 'type of this Asset'
      field :gemini_token, types.String, 'gemini token for asset'
      field :image_urls, GraphQL::Types::JSON, 'known image urls'
      field :submission_id, !types.ID
      field :submissionID, types.ID, property: :submission_id # Alias for MPv2 compatability
    end
end
