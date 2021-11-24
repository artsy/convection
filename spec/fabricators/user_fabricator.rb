# frozen_string_literal: true

Fabricator(:user) do
  gravity_user_id do
    Fabricate.sequence(:gravity_user_id) { |i| "user-id-#{i}" }
  end
  email { Fabricate.sequence(:email) { |i| "jon-jonson#{i}@test.com" } }
  session_id { Fabricate.sequence(:session_id) { |i| "session_id#{i}" } }
end
