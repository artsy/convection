Fabricator(:partner_submission) do
  submission { Fabricate(:submission) }
  partner { Fabricate(:partner) }
end
