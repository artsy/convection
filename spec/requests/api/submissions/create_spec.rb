require 'rails_helper'
require 'support/gravity_helper'

describe 'Create Submission' do
  let(:jwt_token) { JWT.encode({ aud: 'gravity', sub: 'userid', roles: 'user' }, Convection.config.jwt_secret) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  describe 'POST /submissions' do
    it 'rejects unauthorized submissions' do
      post '/api/submissions', params: {
        artist_id: 'artistid'
      }, headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 401
    end

    it 'rejects submissions without an artist_id' do
      post '/api/submissions', params: {}, headers: headers
      expect(response.status).to eq 400
      expect(JSON.parse(response.body)['error']).to eq 'Parameter artist_id is required'
    end

    it 'creates a submission' do
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')

      expect do
        post '/api/submissions', params: {
          title: 'my sartwork',
          artist_id: 'artistid'
        }, headers: headers
      end.to change { Submission.count }.by(1)
    end

    it 'creates a submission with edition fields' do
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')

      expect do
        post '/api/submissions', params: {
          title: 'my sartwork',
          artist_id: 'artistid',
          edition: true,
          edition_size: 100,
          edition_number: '23a',
          category: 'Painting'
        }, headers: headers

        expect(JSON.parse(response.body)['edition_size']).to eq 100
      end.to change { Submission.count }.by(1)
    end

    it 'creates a submission with a minimum price' do
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')

      expect do
        post '/api/submissions', params: {
          title: 'my sartwork',
          artist_id: 'artistid',
          edition: true,
          edition_size: 100,
          edition_number: '23a',
          category: 'Painting',
          minimum_price_dollars: 50_000,
          currency: 'GBP'
        }, headers: headers

        expect(JSON.parse(response.body)['edition_size']).to eq 100
        expect(JSON.parse(response.body)['minimum_price_dollars']).to eq 50_000
        expect(JSON.parse(response.body)['currency']).to eq 'GBP'
      end.to change { Submission.count }.by(1)
    end
  end
end
