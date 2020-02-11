Fabricator(:user) do
  gravity_user_id do
    Fabricate.sequence(:gravity_user_id) { |i| "user-id-#{i}" }
  end
  email { Fabricate.sequence(:email) { |i| "jon-jonson#{i}@test.com" } }
end
