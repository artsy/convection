# frozen_string_literal: true

Fabricator(:admin_user) do
  gravity_user_id do
    Fabricate.sequence(:gravity_user_id) { |i| "user-id-#{i}" }
  end
  name { "jon-jonson" }
  assignee { false }
  cataloguer { false }
end
