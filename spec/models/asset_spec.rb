require 'rails_helper'

describe Asset do
  context 'validations' do
    it 'must have an asset_type' do
      expect(Asset.new(asset_type: 'blah')).not_to be_valid
      expect(Asset.new(asset_type: 'image')).to be_valid
      expect(Asset.new(asset_type: nil)).not_to be_valid
    end
  end

  describe '#update_image_urls!' do
    let(:asset) { Fabricate(:unprocessed_image) }

    it 'adds a new image version url' do
      params = { image_url: { square: 'https://square-image.jpg' } }
      asset.update_image_urls!(params)
      expect(asset.reload.image_urls).to eq('square' => 'https://square-image.jpg')
    end

    it 'adds a new image version url to a pre-populated hash' do
      asset.update_attributes!(image_urls: { round: 'https://round-image.jpg' })
      params = { image_url: { square: 'https://square-image.jpg' } }
      asset.update_image_urls!(params)
      expect(asset.reload.image_urls).to eq('round' => 'https://round-image.jpg',
                                            'square' => 'https://square-image.jpg')
    end

    it 'updates an existing image version url' do
      asset.update_attributes!(image_urls: { round: 'https://round-image.jpg' })
      params = { image_url: { round: 'https://square-image.jpg' } }
      asset.update_image_urls!(params)
      expect(asset.reload.image_urls).to eq('round' => 'https://square-image.jpg')
    end

    it 'does nothing if the params are empty' do
      asset.update_attributes!(image_urls: { round: 'https://round-image.jpg' })
      params = { image_url: {} }
      asset.update_image_urls!(params)
      expect(asset.reload.image_urls).to eq('round' => 'https://round-image.jpg')
    end
  end

  describe '#original_image' do
    let(:asset) { Fabricate(:image, gemini_token: nil) }

    before do
      allow(Convection.config).to receive(:gemini_app).and_return('https://media-test.artsy.net')
      allow(Convection.config).to receive(:gemini_account_key).and_return('convection-test')
    end

    it 'does nothing if there is no gemini_token' do
      expect { asset.original_image }.to_not raise_error
    end

    it 'returns an image location' do
      asset.update_attributes!(gemini_token: 'foo')
      stub_request(:get, 'https://media-test.artsy.net/original.json?token=foo').to_return(status: 302)
      expect { asset.original_image }.to_not raise_error
    end

    it 'raises an exception if the response is not successful' do
      asset.update_attributes!(gemini_token: 'foo')
      stub_request(:get, 'https://media-test.artsy.net/original.json?token=foo').to_return(status: 400, body: 'ruh roh')
      expect { asset.original_image }.to raise_error { |e| expect(e.message).to eq('400: ruh roh') }
    end
  end
end
