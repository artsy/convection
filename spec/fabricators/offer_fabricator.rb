# frozen_string_literal: true

Fabricator(:offer) do
  partner_submission { Fabricate(:partner_submission) }
  offer_type { 'purchase' }
  state 'sent'
  price_cents 120_000
  commission_percent 0.5
end
