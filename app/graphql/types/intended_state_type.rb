# frozen_string_literal: true

module Types
  class IntendedStateType < Types::BaseEnum
    value('ACCEPTED', nil, value: 'accepted')
    value('REJECTED', nil, value: 'rejected')
    value('REVIEW', nil, value: 'review')
  end
end
