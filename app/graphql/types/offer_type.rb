# frozen_string_literal: true

module Types
  class OfferType < Types::BaseObject
    description 'Consignment Offer'

    field :id, ID, 'Uniq ID for this submission', null: false
  end
end
