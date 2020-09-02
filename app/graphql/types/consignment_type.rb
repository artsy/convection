# frozen_string_literal: true

module Types
  class ConsignmentType < Types::BaseObject
    description 'Consignment'

    field :submission_id, ID, null: false
    field :submissionID, ID, null: true # Alias for MPv2 compatability
    field :sale_date, String, null: true
    field :sale_name, String, null: true
    field :state, Types::ConsignmentStateType, null: true
    field :id, ID, 'Uniq ID for this consignment', null: false
    field :currency, String, null: true
    field :internalID, ID, method: :id, null: true
    field :sale_price_cents, Integer, null: true
    field :submission, Types::SubmissionType, null: false
  end
end
  