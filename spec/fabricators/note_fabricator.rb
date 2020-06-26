# frozen_string_literal: true

Fabricator(:note) do
  created_by do
    Fabricate(:user).id
  end
  body { Fabricate.sequence(:email) { |i| "I'm note #{i}" } }
  submission { Fabricate(:submission )}
end
