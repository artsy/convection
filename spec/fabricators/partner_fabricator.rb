Fabricator(:partner) do
  gravity_partner_id { Fabricate.sequence(:gravity_partner_id) { |i| "partner-id-#{i}" } }
  name { Fabricate.sequence(:name) { |i| "Gallery #{i}" } }
end
