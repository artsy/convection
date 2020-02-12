# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe 'Show Submission' do
  let!(:user) { Fabricate(:user, gravity_user_id: 'userid') }
  let(:jwt_token) do
    JWT.encode({ aud: 'gravity', sub: 'userid' }, Convection.config.jwt_secret)
  end
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  describe 'GET /submissions' do
    it 'rejects unauthorized requests' do
      get '/api/submissions',
          headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 401
    end

    it "doesn't return other people's submissions" do
      Fabricate(
        :submission,
        user: Fabricate(:user, gravity_user_id: 'buster-bluth'),
        state: 'approved'
      )
      get '/api/submissions', headers: headers
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body).to eq []
    end

    it 'returns your own submissions' do
      submission = Fabricate(:submission, user: user, state: 'approved')
      Fabricate(
        :submission,
        user: Fabricate(:user, gravity_user_id: 'buster-bluth'),
        state: 'approved'
      )

      get '/api/submissions', headers: headers
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body.length).to eq 1
      expect(body[0]['id']).to eq submission.id
    end

    it 'handles pagination correctly with your submissions' do
      submission = Fabricate(:submission, user: user, state: 'approved')
      Fabricate(:submission, user: user, state: 'approved')
      Fabricate(:submission, user: user, state: 'approved')

      get '/api/submissions', headers: headers, params: { page: 3, size: 1 }
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body.first['id']).to eq submission.id
    end

    describe 'filtering' do
      it 'defaults to all types of submissions submissions' do
        Fabricate(:submission, user: user, state: 'approved')
        Fabricate(:submission, user: user, state: 'draft')
        Fabricate(:submission, user: user, state: 'approved')

        get '/api/submissions', headers: headers
        expect(response.status).to eq 200

        body = JSON.parse(response.body)
        expect(body.length).to eq 3
      end

      it 'supports only passing completed submissions' do
        submission = Fabricate(:submission, user: user, state: 'approved')
        Fabricate(:submission, user: user, state: 'draft')
        submission3 = Fabricate(:submission, user: user, state: 'approved')

        get '/api/submissions', headers: headers, params: { completed: true }
        expect(response.status).to eq 200

        body = JSON.parse(response.body)
        expect(body.length).to eq 2

        expect(body[0]['id']).to eq submission3.id
        expect(body[1]['id']).to eq submission.id
      end

      it 'supports only passing draft submissions' do
        Fabricate(:submission, user: user, state: 'approved')
        submission2 = Fabricate(:submission, user: user, state: 'draft')
        Fabricate(:submission, user: user, state: 'approved')

        get '/api/submissions', headers: headers, params: { completed: false }
        expect(response.status).to eq 200

        body = JSON.parse(response.body)
        expect(body.length).to eq 1

        expect(body[0]['id']).to eq submission2.id
      end
    end
  end
end
