# frozen_string_literal: true

module Types
  class StateType < Types::BaseEnum
    value('DRAFT', nil, value: 'draft')
    value('SUBMITTED', nil, value: 'submitted')
    value('APPROVED', nil, value: 'approved')
    value('REJECTED', nil, value: 'rejected')
  end
end
