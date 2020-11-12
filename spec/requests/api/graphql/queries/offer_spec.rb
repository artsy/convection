# frozen_string_literal: true

require 'rails_helper'

describe 'offer query' do
  let(:partner) { Fabricate :partner }
  let(:partner_submission) { Fabricate :partner_submission, partner: partner }
  let!(:offer) { Fabricate :offer, partner_submission: partner_submission }

  let(:token) do
    JWT.encode(
      { aud: 'gravity', sub: 'userid', roles: 'admin' },
      Convection.config.jwt_secret
    )
  end

  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  let(:query_inputs) do
    "id: \"#{offer.id}\", gravityPartnerId: \"#{partner.gravity_partner_id}\""
  end

  let(:query) do
    <<-GRAPHQL
    query {
      offer(#{query_inputs}) {
        id
        commissionPercentWhole
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

        offer_response = body.dig('data', 'offer')
        expect(offer_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq "Can't access offer"
      end
    end

    context 'with a request from a regular user' do
      let(:token) do
        payload = { aud: 'gravity', sub: 'userid', roles: 'user' }
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      it 'returns an error for that request if the user is not the offer owner' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        offer_response = body.dig('data', 'offer')
        expect(offer_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq 'Offer not found'
      end
    end
  end

  describe 'valid requests' do
    context 'with an invalid offer id' do
      let(:query_inputs) do
        "id: 999999999, gravityPartnerId: \"#{partner.gravity_partner_id}\""
      end

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        offer_response = body.dig('data', 'offer')
        expect(offer_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq 'Offer not found'
      end
    end

    context 'with an existing offer id' do
      it 'returns that offer' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        offer_response = body.dig('data', 'offer')
        expect(offer_response).to match(
          {
            'id' => offer.id.to_s,
            'commissionPercentWhole' => offer.commission_percent_whole
          }
        )
      end
    end

    context 'with a valid offer id from a partner' do
      let(:token) do
        payload = { aud: 'gravity', sub: 'userid', roles: 'partner' }
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      it 'returns that offer' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        offer_response = body.dig('data', 'offer')
        expect(offer_response).to match(
          {
            'id' => offer.id.to_s,
            'commissionPercentWhole' => offer.commission_percent_whole
          }
        )
      end
    end

    context 'with a valid offer id and an admin accessing' do
      let(:token) do
        payload = { aud: 'gravity', sub: 'userid', roles: 'admin' }
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      it 'returns that offer' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        offer_response = body.dig('data', 'offer')
        expect(offer_response).to match(
          {
            'id' => offer.id.to_s,
            'commissionPercentWhole' => offer.commission_percent_whole
          }
        )
      end
    end

    context 'with a user accessing their own offer' do
      let(:token) do
        user_id = offer.submission.user.gravity_user_id
        payload = { aud: 'gravity', sub: user_id, roles: 'admin' }
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      it 'returns that offer' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        offer_response = body.dig('data', 'offer')
        expect(offer_response).to match(
          {
            'id' => offer.id.to_s,
            'commissionPercentWhole' => offer.commission_percent_whole
          }
        )
      end
    end

    context 'with an offer id from another partner' do
      let(:token) do
        payload = { aud: 'gravity', sub: 'userid', roles: 'partner' }
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      let(:another_partner) { Fabricate :partner }
      let(:query_inputs) do
        "id: \"#{offer.id}\", gravityPartnerId: \"#{
          another_partner.gravity_partner_id
        }\""
      end

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        offer_response = body.dig('data', 'offer')
        expect(offer_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq 'Offer not found'
      end
    end
  end
end
