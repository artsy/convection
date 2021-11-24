# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe 'Show Submission' do
  let(:jwt_token) do
    JWT.encode({ aud: 'gravity', sub: 'userid' }, Convection.config.jwt_secret)
  end
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  describe 'GET /submissions' do
    it 'rejects unauthorized requests' do
      get '/api/submissions/foo',
          headers: {
            'Authorization' => 'Bearer foo.bar.baz'
          }
      expect(response.status).to eq 401
    end

    it 'returns an error if it cannot find the submission' do
      Fabricate(
        :submission,
        user: Fabricate(:user, gravity_user_id: 'buster-bluth')
      )
      get '/api/submissions/foo', headers: headers
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['error']).to eq 'Not Found'
    end

    it "rejects requests for someone else's submission" do
      submission =
        Fabricate(
          :submission,
          user: Fabricate(:user, gravity_user_id: 'buster-bluth')
        )
      get "/api/submissions/#{submission.id}", headers: headers
      expect(response.status).to eq 401
    end

    it 'accepts requests for your own submission' do
      submission =
        Fabricate(
          :submission,
          user: Fabricate(:user, gravity_user_id: 'userid')
        )
      get "/api/submissions/#{submission.id}", headers: headers
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body['user_id']).to eq submission.user.id
      expect(body['id']).to eq submission.id
    end
  end
end
