require 'rails_helper'

describe UrlHelper, type: :helper do
  before do
    allow(Convection.config).to receive(:artsy_url).and_return(
      'https://test.artsy.net'
    )
  end

  describe '#upload_photo_url' do
    it 'returns a url without utm params if none are provided' do
      expect(helper.upload_photo_url(19)).to eq(
        'https://test.artsy.net/consign/submission/19/upload?'
      )
    end
    it 'returns a url with utm params if some are provided' do
      utm_params = { utm_source: 'reminder', utm_campaign: 'consignments' }
      expect(helper.upload_photo_url(19, utm_params)).to eq(
        'https://test.artsy.net/consign/submission/19/upload?utm_campaign=consignments&utm_source=reminder'
      )
    end
  end

  describe '#offer_form_url' do
    before do
      allow(Convection.config).to receive(:auction_offer_form_url).and_return(
        'https://google.com/auction?entry.blahblah=SUBMISSION_NUMBER'
      )
    end

    it 'returns the correct url for an auction' do
      expect(helper.offer_form_url).to eq(
        'https://google.com/auction?entry.blahblah='
      )
    end

    it 'correctly replaces the submission number if one is supplied' do
      expect(helper.offer_form_url(submission_id: 123)).to eq(
        'https://google.com/auction?entry.blahblah=123'
      )
    end
  end

  describe '#offer_response_form_url' do
    before do
      allow(Convection.config).to receive(:offer_response_form_url).and_return(
        'https://google.com/response?entry.blahblah=SUBMISSION_NUMBER&entry.blah2=PARTNER_NAME'
      )
    end

    it 'returns the correct url for a user to respond' do
      expect(helper.offer_response_form_url).to eq(
        'https://google.com/response?entry.blahblah=&entry.blah2='
      )
    end

    it 'correctly replaces the submission number if one is supplied' do
      expect(
        helper.offer_response_form_url(
          submission_id: 123, partner_name: 'gagosian gallery'
        )
      ).to eq(
        'https://google.com/response?entry.blahblah=123&entry.blah2=gagosian gallery'
      )
    end
  end
end
