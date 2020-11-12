# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe 'createConsignmentOfferResponse mutation' do
  let!(:offer) { Fabricate :offer }

  let(:token) do
    user_id = offer.submission.user.gravity_user_id
    payload = { aud: 'gravity', sub: user_id, roles: 'user' }
    JWT.encode(payload, Convection.config.jwt_secret)
  end

  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  let(:mutation_inputs) do
    <<-INPUTS
    {
      offerId: "#{offer.id}",
      intendedState: ACCEPTED
    }
    INPUTS
  end

  let(:mutation) do
    <<-GRAPHQL
    mutation {
      createConsignmentOfferResponse(input: #{mutation_inputs}){
        consignmentOfferResponse {
          id
        }
      }
    }
    GRAPHQL
  end

  describe 'invalid requests' do
    context 'with an unauthorized request' do
      let(:token) { 'foo.bar.baz' }

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        create_response = body['data']['createConsignmentOfferResponse']
        expect(create_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(
          error_message
        ).to eq "Can't access createConsignmentOfferResponse"
      end
    end

    context "with a request for someone else's offer" do
      let(:token) do
        payload = { aud: 'gravity', sub: 'userid', roles: 'user' }
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        create_response = body['data']['createConsignmentOfferResponse']
        expect(create_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq 'Offer not found'
      end
    end

    context 'with a request missing an offer id' do
      let(:mutation_inputs) do
        <<-INPUTS
        {
          intendedState: "accepted"
        }
        INPUTS
      end

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        error_message = body['errors'][0]['message']
        expect(error_message).to match 'is required'
      end
    end

    context 'with a request missing an intended state' do
      let(:mutation_inputs) do
        <<-INPUTS
        {
          offerId: #{offer.id}
        }
        INPUTS
      end

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        error_message = body['errors'][0]['message']
        expect(error_message).to match 'is required'
      end
    end

    context 'with an invalid intended state' do
      let(:mutation_inputs) do
        <<-INPUTS
        {
          intendedState: "blah",
          offerId: #{offer.id}
        }
        INPUTS
      end

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        error_message = body['errors'][0]['message']
        expect(error_message).to match 'has an invalid value'
      end
    end

    context 'with an invalid rejection reason' do
      let(:mutation_inputs) do
        <<-INPUTS
        {
          intendedState: REJECTED,
          rejectionReason: "meow",
          offerId: #{offer.id}
        }
        INPUTS
      end

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        error_message = body['errors'][0]['message']
        expect(error_message).to match 'Validation failed'
      end
    end
  end

  describe 'valid requests' do
    context 'with just the minimum' do
      it 'creates an offer response' do
        expect {
          post '/api/graphql', params: { query: mutation }, headers: headers
        }.to change(OfferResponse, :count).by(1)

        expect(response.status).to eq 200
        body = JSON.parse(response.body)
        create_response = body['data']['createConsignmentOfferResponse']

        offer_response = OfferResponse.last

        expect(create_response['consignmentOfferResponse']).to include(
          { 'id' => offer_response.id.to_s }
        )
      end
    end

    context 'with more fields' do
      let(:mutation_inputs) do
        <<-INPUTS
        {
          offerId: "#{offer.id}",
          intendedState: REJECTED,
          rejectionReason: "Low estimate",
          phoneNumber: "123-456-7890",
          comments: "Cool offer but no thanks."
        }
        INPUTS
      end

      it 'creates an offer response' do
        expect {
          post '/api/graphql', params: { query: mutation }, headers: headers
        }.to change(OfferResponse, :count).by(1)

        expect(response.status).to eq 200
        body = JSON.parse(response.body)
        create_response = body['data']['createConsignmentOfferResponse']

        offer_response = OfferResponse.last

        expect(create_response['consignmentOfferResponse']).to include(
          { 'id' => offer_response.id.to_s }
        )
      end
    end
  end
end
