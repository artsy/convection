# frozen_string_literal: true

module Types
  class ConsignmentStateType < Types::BaseEnum
    value("OPEN", nil, value: "open")
    value("CANCELLED", nil, value: "cancelled")
    value("SOLD", nil, value: "sold")
    value("BOUGHT_IN", nil, value: "bought in")
  end
end
