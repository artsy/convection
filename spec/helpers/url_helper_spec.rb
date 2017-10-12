require 'rails_helper'

describe UrlHelper, type: :helper do
  before do
    allow(Convection.config).to receive(:artsy_url).and_return('https://test.artsy.net')
  end

  describe '#upload_photo_url' do
    it 'returns a url without utm params if none are provided' do
      expect(helper.upload_photo_url(19)).to eq('https://test.artsy.net/consign/submission/19/upload?')
    end
    it 'returns a url with utm params if some are provided' do
      utm_params = { utm_source: 'reminder', utm_campaign: 'consignments' }
      expect(helper.upload_photo_url(19, utm_params)).to eq('https://test.artsy.net/consign/submission/19/upload?utm_campaign=consignments&utm_source=reminder')
    end
  end

  describe '#offer_form_url' do
    before do
      allow(Convection.config).to receive(:auction_offer_form_url).and_return('https://google.com/auction')
    end

    it 'returns the correct url for an auction' do
      expect(helper.offer_form_url).to eq('https://google.com/auction')
    end
  end
end
