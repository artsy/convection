# frozen_string_literal: true

module Types
  class AttributionClassType < Types::BaseEnum
    # these values correspond to the attribution_class enum keys in the submission model

    value('UNIQUE', nil, value: 'unique')
    value('LIMITED_EDITION', nil, value: 'limited_edition')
    value('OPEN_EDITION', nil, value: 'open_edition')
    value('UNKNOWN_EDITION', nil, value: 'unknown_edition')
  end
end
