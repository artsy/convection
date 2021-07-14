# frozen_string_literal: true

Fabricator(:admin_user) do
  gravity_user_id do
    Fabricate.sequence(:gravity_user_id) { |i| "user-id-#{i}" }
  end
  name { Fabricate.sequence(:name) { "jon-jonson" } }
  name { Fabricate.boolean(:admin) { false } }
  name { Fabricate.boolean(:cataloguers) { false } }
end
