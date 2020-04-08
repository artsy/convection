# frozen_string_literal: true

require 'rails_helper'

describe 'submission query' do
  let(:submission) { Fabricate :submission }

  let(:token) do
    JWT.encode(
      { aud: 'gravity', sub: 'userid', roles: 'admin' },
      Convection.config.jwt_secret
    )
  end

  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  let(:query_inputs) { "id: #{submission.id}" }

  let(:query) do
    <<-GRAPHQL
    query {
      submission(#{query_inputs}) {
        id,
        artistId,
        title
      }
    }
    GRAPHQL
  end

  describe 'invalid requests' do
    context 'with an unauthorized request' do
      let(:token) { 'foo.bar.baz' }

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submission_response = body['data']['submission']
        expect(submission_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq "Can't access submission"
      end
    end

    context 'with a request from a regular user' do
      let(:token) do
        payload = { aud: 'gravity', sub: 'userid', roles: 'user' }
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submission_response = body['data']['submission']
        expect(submission_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq "Can't access submission"
      end
    end
  end

  describe 'valid requests' do
    context 'with an invalid submission id' do
      let(:query_inputs) { 'id: 999999999' }

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submission_response = body['data']['submission']
        expect(submission_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq 'Submission not found'
      end
    end

    context 'with an existing submission id' do
      it 'returns that submission' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submission_response = body['data']['submission']
        expect(submission_response).to match(
          {
            'id' => submission.id.to_s,
            'artistId' => submission.artist_id,
            'title' => submission.title
          }
        )
      end
    end

    context 'with a valid submission id from a partner' do
      let(:token) do
        payload = { aud: 'gravity', sub: 'userid', roles: 'partner' }
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      it 'returns that submission' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submission_response = body['data']['submission']
        expect(submission_response).to match(
          {
            'id' => submission.id.to_s,
            'artistId' => submission.artist_id,
            'title' => submission.title
          }
        )
      end
    end

    context 'including offers' do
      let(:partner) { Fabricate :partner }
      let(:partner_submission) do
        Fabricate :partner_submission, partner: partner, submission: submission
      end
      let!(:offer) { Fabricate :offer, partner_submission: partner_submission }

      let!(:another_offer) do
        partner_submission =
          Fabricate :partner_submission, submission: submission
        Fabricate :offer, partner_submission: partner_submission
      end

      let(:query) do
        <<-GRAPHQL
        query {
          submission(#{query_inputs}) {
            offers(gravityPartnerId: "#{partner.gravity_partner_id}") {
              id
              state
              commissionPercentWhole
            }
          }
        }
        GRAPHQL
      end

      it 'returns the offers for that submission' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submission_response = body['data']['submission']
        offers_response = submission_response['offers']
        expect(offers_response.count).to eq 1

        offer_response = offers_response.first
        expect(offer_response).to match(
          {
            'id' => offer.id.to_s,
            'state' => offer.state,
            'commissionPercentWhole' => offer.commission_percent_whole
          }
        )
      end
    end
  end
end
