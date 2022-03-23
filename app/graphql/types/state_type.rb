# frozen_string_literal: true

module Types
  class StateType < Types::BaseEnum
    description 'Enum with all submission states for Create or Update Submission'

    value('DRAFT', nil, value: 'draft')
    value('SUBMITTED', nil, value: 'submitted')
    value('APPROVED', nil, value: 'approved')
    value('REJECTED', nil, value: 'rejected')
  end
end
