# frozen_string_literal: true

Fabricator(:note) do
  gravity_user_id { Fabricate(:user).gravity_user_id }
  body { Fabricate.sequence(:email) { |i| "I'm note #{i}" } }
  submission { Fabricate(:submission) }
end
