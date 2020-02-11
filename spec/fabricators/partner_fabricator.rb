Fabricator(:partner) do
  gravity_partner_id do
    Fabricate.sequence(:gravity_partner_id) { |i| "partner-id-#{i}" }
  end
  name { Fabricate.sequence(:name) { |i| "Gallery #{i}" } }
end
