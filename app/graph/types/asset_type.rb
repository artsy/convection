module Types
  AssetType =
    GraphQL::ObjectType.define do
      name 'Asset'
      description 'Submission Asset'

      field :id, !types.ID, 'Uniq ID for this asset'
      field :asset_type, !types.String, 'type of this Asset'
      field :gemini_token, types.String, 'gemini token for asset'
      field :submission_id, !types.ID
    end
end
