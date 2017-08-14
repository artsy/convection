Fabricator(:partner) do
  external_partner_id { Fabricate.sequence(:external_partner_id) { |i| "partner-id-#{i}" } }
end
