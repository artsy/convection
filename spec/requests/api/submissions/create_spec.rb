# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe 'Create Submission' do
  let(:jwt_token) do
    JWT.encode(
      { aud: 'gravity', sub: 'userid', roles: 'user' },
      Convection.config.jwt_secret
    )
  end
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  describe 'POST /submissions' do
    it 'rejects unauthorized submissions' do
      post '/api/submissions',
           params: { artist_id: 'artistid' },
           headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 401
    end

    it 'rejects submissions without an artist_id' do
      post '/api/submissions', params: {}, headers: headers
      expect(response.status).to eq 400
      expect(
        JSON.parse(response.body)['error']
      ).to eq 'Parameter artist_id is required'
    end

    it 'creates a submission' do
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')

      expect {
        post '/api/submissions',
             params: { title: 'my sartwork', artist_id: 'artistid' },
             headers: headers
      }.to change { Submission.count }.by(1)
    end

    it 'creates a submission with edition fields' do
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')

      expect {
        post '/api/submissions',
             params: {
               title: 'my sartwork',
               artist_id: 'artistid',
               edition: true,
               edition_size: 100,
               edition_number: '23a',
               category: 'Painting'
             },
             headers: headers

        expect(JSON.parse(response.body)['edition_size']).to eq 100
      }.to change { Submission.count }.by(1)
    end

    it 'creates a submission with a minimum price' do
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')

      expect {
        post '/api/submissions',
             params: {
               title: 'my sartwork',
               artist_id: 'artistid',
               edition: true,
               edition_size: 100,
               edition_number: '23a',
               category: 'Painting',
               minimum_price_dollars: 50_000,
               currency: 'GBP'
             },
             headers: headers.merge('User-Agent' => 'Eigen')

        expect(JSON.parse(response.body)['edition_size']).to eq 100
        expect(JSON.parse(response.body)['minimum_price_dollars']).to eq 50_000
        expect(JSON.parse(response.body)['currency']).to eq 'GBP'
        expect(JSON.parse(response.body)['user_agent']).to eq 'Eigen'
      }.to change { Submission.count }.by(1)
    end
  end
end
