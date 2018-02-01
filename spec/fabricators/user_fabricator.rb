Fabricator(:user) do
  gravity_user_id { Fabricate.sequence(:gravity_user_id) { |i| "user-id-#{i}" } }
  email { Fabricate.sequence(:email) { |i| "jon-jonson#{i}@test.com" } }
end
