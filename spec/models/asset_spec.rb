require 'rails_helper'

describe Asset do
  context 'validations' do
    it 'must have an asset_type' do
      expect(Asset.new(asset_type: 'blah')).not_to be_valid
      expect(Asset.new(asset_type: 'image')).to be_valid
    end
  end
end
