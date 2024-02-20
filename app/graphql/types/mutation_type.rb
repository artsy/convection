# frozen_string_literal: true

module Types
  class MutationType < GraphQL::Schema::Object
    description "Mutation root for this schema"

    field :add_asset_to_consignment_submission,
          mutation: Mutations::AddAssetToConsignmentSubmission
    field :remove_asset_from_consignment_submission,
          mutation: Mutations::RemoveAssetFromConsignmentSubmission
    field :add_assets_to_consignment_submission,
          mutation: Mutations::AddAssetsToConsignmentSubmission
    field :create_consignment_offer, mutation: Mutations::CreateOfferMutation
    field :create_consignment_offer_response,
          mutation: Mutations::CreateOfferResponseMutation
    field :create_consignment_submission,
          mutation: Mutations::CreateSubmissionMutation
    field :update_consignment_submission,
          mutation: Mutations::UpdateSubmissionMutation
    field :add_user_to_submission,
          mutation: Mutations::AddUserToSubmissionMutation
  end
end
