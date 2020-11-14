# frozen_string_literal: true

Fabricator(:offer_response) do
  offer { Fabricate(:offer) }
  intended_state 'accepted'
end
