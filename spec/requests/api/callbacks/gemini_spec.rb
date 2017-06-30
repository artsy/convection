require 'rails_helper'
require 'support/gravity_helper'

describe 'Gemini Callback' do
  let(:submission) { Fabricate(:submission, artist_id: 'andy-warhol', user_id: 'userid') }

  before do
    allow(Convection.config).to receive(:access_token).and_return('auth-token')
  end

  describe 'POST /gemini' do
    it 'rejects unauthorized callbacks' do
      post '/api/callbacks/gemini', params: {
        access_token: 'wrong-token',
        token: 'gemini',
        image_url: { square: 'https://new-image.jpg' },
        metadata: { id: submission.id, _type: 'Consignment' }
      }
      expect(response.status).to eq 401
    end

    it 'rejects callbacks without an image_url' do
      post '/api/callbacks/gemini', params: {
        access_token: 'auth-token',
        token: 'gemini',
        'metadata' => { id: submission.id, _type: 'Consignment' }
      }
      expect(response.status).to eq 400
    end

    it 'rejects callbacks if there is no matching asset' do
      post '/api/callbacks/gemini', params: {
        access_token: 'auth-token',
        token: 'gemini',
        image_url: { square: 'https://new-image.jpg' },
        metadata: { id: submission.id, _type: 'Consignment' }
      }

      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['error']).to eq 'Not Found'
    end

    it 'updates the asset to have the right image url' do
      Fabricate(:unprocessed_image, submission: submission, gemini_token: 'gemini')
      post '/api/callbacks/gemini', params: {
        access_token: 'auth-token',
        token: 'gemini',
        image_url: { square: 'https://new-image.jpg' },
        metadata: { id: submission.id, _type: 'Consignment' }
      }

      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['submission_id']).to eq(submission.id)
      expect(JSON.parse(response.body)['image_urls']).to eq('square' => 'https://new-image.jpg')
    end
  end
end
