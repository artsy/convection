# frozen_string_literal: true

module Types
  class OfferSortType < SortType
    generate_values(Offer.column_names)
  end
end
