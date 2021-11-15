# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe 'POST /api/submissions' do
  let(:jwt_token) do
    payload = { aud: 'gravity', sub: 'userid', roles: 'user' }
    JWT.encode(payload, Convection.config.jwt_secret)
  end

  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  context 'with an unauthorized submission' do
    let(:headers) { { 'Authorization' => 'Bearer foo.bar.baz' } }

    it 'returns a 401' do
      params = { artist_id: 'artistid' }
      post '/api/submissions', params: params, headers: headers
      expect(response.status).to eq 401
    end
  end

  context 'without an artist id' do
    it 'returns a 400 with an error message' do
      params = {}
      post '/api/submissions', params: params, headers: headers
      expect(response.status).to eq 400
      response_json = JSON.parse(response.body)
      expect(response_json['error']).to eq 'Parameter artist_id is required'
    end
  end

  context 'with an authorized submission and artist id' do
    it 'returns a 201 and creates a submission' do
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')
      stub_gravity_artist({ id: 'artistid' })

      params = { title: 'my sartwork', artist_id: 'artistid' }

      expect do
        post '/api/submissions', params: params, headers: headers
      end.to change { Submission.count }.by(1)

      expect(response.status).to eq 201
    end
  end

  context 'with an editioned submission' do
    it 'returns a 201 and creates a submission with edition fields' do
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')
      stub_gravity_artist({ id: 'artistid' })

      params = {
        artist_id: 'artistid',
        category: 'Painting',
        edition: true,
        edition_number: '23a',
        edition_size: 100,
        title: 'my sartwork'
      }

      expect do
        post '/api/submissions', params: params, headers: headers
      end.to change { Submission.count }.by(1)

      expect(response.status).to eq 201

      response_json = JSON.parse(response.body)
      expect(response_json['edition_size']).to eq '100'
    end
  end

  context 'with a submission that includes a minimum price' do
    it 'returns a 201 and creates a submission with that minimum price' do
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')
      stub_gravity_artist({ id: 'artistid' })

      params = {
        artist_id: 'artistid',
        category: 'Painting',
        currency: 'GBP',
        edition: true,
        edition_number: '23a',
        edition_size: 100,
        minimum_price_dollars: 50_000,
        title: 'my sartwork'
      }

      eigen_headers = headers.merge('User-Agent' => 'Eigen')

      expect do
        post '/api/submissions', params: params, headers: eigen_headers
      end.to change { Submission.count }.by(1)

      expect(response.status).to eq 201

      response_json = JSON.parse(response.body)
      expect(response_json['edition_size']).to eq '100'
      expect(response_json['minimum_price_dollars']).to eq 50_000
      expect(response_json['currency']).to eq 'GBP'
      expect(response_json['user_agent']).to eq 'Eigen'
    end
  end

  context 'with a submission that includes a edition_size_formatted' do
    it 'returns a 201 and creates a submission with that edition_size_formatted' do
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')
      stub_gravity_artist({ id: 'artistid' })

      params = {
        artist_id: 'artistid',
        category: 'Painting',
        currency: 'GBP',
        edition: true,
        edition_number: '23a',
        edition_size: 100,
        edition_size_formatted: '120',
        minimum_price_dollars: 50_000,
        title: 'my sartwork'
      }

      eigen_headers = headers.merge('User-Agent' => 'Eigen')

      expect do
        post '/api/submissions', params: params, headers: eigen_headers
      end.to change { Submission.count }.by(1)

      expect(response.status).to eq 201

      response_json = JSON.parse(response.body)
      expect(response_json['edition_size']).to eq '120'
      expect(response_json['minimum_price_dollars']).to eq 50_000
      expect(response_json['currency']).to eq 'GBP'
      expect(response_json['user_agent']).to eq 'Eigen'
    end
  end

  # Below commented out for now to be revisited when we are implementing anonymous submission

  # context 'with a trusted app token' do
  #   let(:jwt_token) do
  #     payload = { aud: 'force', roles: 'trusted' }
  #     JWT.encode(payload, Convection.config.jwt_secret)
  #   end

  #   it 'uses the anonymous user' do
  #     stub_gravity_artist({ id: 'artistid' })

  #     params = {
  #       artist_id: 'artistid',
  #       gravity_user_id: 'anonymous',
  #       title: 'my artwork'
  #     }

  #     expect do
  #       post '/api/submissions', params: params, headers: headers
  #     end.to change { User.anonymous.submissions.count }.by(1)
  #   end
  # end
end
