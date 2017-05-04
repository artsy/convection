require 'rails_helper'

describe Asset do
  context 'validations' do
    it 'must have an asset_type' do
      expect(Asset.new(asset_type: 'blah')).not_to be_valid
      expect(Asset.new(asset_type: 'image')).to be_valid
    end
  end

  describe '#update_image_urls!' do
    let(:asset) { Asset.create!(asset_type: 'image') }

    it 'adds a new image version url' do
      params = { image_url: { square: 'https://square-image.jpg' } }
      asset.update_image_urls!(params)
      expect(asset.image_urls).to eq('square' => 'https://square-image.jpg')
    end

    it 'adds a new image version url to a pre-populated hash' do
      asset.update_attributes!(image_urls: { round: 'https://round-image.jpg' })
      params = { image_url: { square: 'https://square-image.jpg' } }
      asset.update_image_urls!(params)
      expect(asset.image_urls).to eq('round' => 'https://round-image.jpg',
                                     'square' => 'https://square-image.jpg')
    end

    it 'updates an existing image version url' do
      asset.update_attributes!(image_urls: { round: 'https://round-image.jpg' })
      params = { image_url: { round: 'https://square-image.jpg' } }
      asset.update_image_urls!(params)
      expect(asset.image_urls).to eq('round' => 'https://square-image.jpg')
    end

    it 'does nothing if the params are empty' do
      asset.update_attributes!(image_urls: { round: 'https://round-image.jpg' })
      params = { image_url: {} }
      asset.update_image_urls!(params)
      expect(asset.image_urls).to eq('round' => 'https://round-image.jpg')
    end
  end
end
