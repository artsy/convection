module Types
  AssetType = GraphQL::ObjectType.define do
    name 'Asset'
    description 'Submission Asset'

    field :id, !types.ID, 'Uniq ID for this asset'
    field :asset_type, !types.String, 'type of this Asset'
    field :image_urls, Types::JsonType, 'Json of available image urls'
    field :submission, !Types::SubmissionType
  end
end
