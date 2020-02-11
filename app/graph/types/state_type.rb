module Types
  StateType =
    GraphQL::EnumType.define do
      name 'State'
      value('DRAFT', nil, value: 'draft')
      value('SUBMITTED', nil, value: 'submitted')
      value('APPROVED', nil, value: 'approved')
      value('REJECTED', nil, value: 'rejected')
    end
end
