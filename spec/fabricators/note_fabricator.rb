# frozen_string_literal: true

Fabricator(:note) do
  created_by { Fabricate(:user).id }
  body { Fabricate.sequence(:email) { |i| "I'm note #{i}" } }
  submission { Fabricate(:submission) }
end
