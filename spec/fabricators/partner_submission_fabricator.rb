Fabricator(:partner_submission) do
  submission { Fabricate(:submission) }
  partner { Fabricate(:partner) }
end

Fabricator(:consignment, from: :partner_submission) do
  submission { Fabricate(:submission) }
  partner { Fabricate(:partner) }
  accepted_offer { Fabricate(:offer, state: 'accepted') }
end
