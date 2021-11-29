# frozen_string_literal: true

require 'rails_helper'

describe 'consignments query' do
  let(:partner) { Fabricate :partner }
  let!(:consignment1) do
    Fabricate(:partner_submission, state: 'bought in', partner: partner)
  end

  let!(:consignment2) do
    Fabricate(:partner_submission, state: 'sold', partner: partner)
  end

  let!(:consignment3) do
    Fabricate(:partner_submission, state: 'open', partner: partner)
  end

  let!(:consignment4) do
    Fabricate(:partner_submission, state: 'bought in', partner: partner)
  end

  let!(:consignment5) do
    Fabricate(:partner_submission, state: 'sold', partner: partner)
  end

  let(:token) do
    JWT.encode(
      { aud: 'gravity', sub: 'userid', roles: 'partner' },
      Convection.config.jwt_secret
    )
  end

  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  let(:query_inputs) { "gravityPartnerId: \"#{partner.gravity_partner_id}\"" }
  let(:query) { <<-GRAPHQL }
    query {
      consignments(#{query_inputs}) {
        totalCount
        edges {
          node {
            currency
            state
          }
        }
      }
    }
  GRAPHQL

  describe 'invalid requests' do
    context 'with an unauthorized request' do
      let(:token) { 'foo.bar.baz' }

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)
        consignments_response = body['data']['consignments']
        expect(consignments_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq "Can't find partner."
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

        consignments_response = body['data']['consignments']
        expect(consignments_response).to eq nil

        error_message = body['errors'][0]['message']

        expect(error_message).to eq "Can't find partner."
      end
    end
  end

  describe 'valid requests' do
    it 'returns the expected graphql response' do
      post '/api/graphql', params: { query: query }, headers: headers

      expect(response.status).to eq 200
      body = JSON.parse(response.body)

      expect(body['data']).to eq(
        {
          consignments: {
            totalCount: 4,
            edges: [
              { node: { currency: 'USD', state: 'SOLD' } },
              { node: { currency: 'USD', state: 'BOUGHT_IN' } },
              { node: { currency: 'USD', state: 'SOLD' } },
              { node: { currency: 'USD', state: 'BOUGHT_IN' } }
            ]
          }
        }.deep_stringify_keys
      )
    end
    it 'returns only sold or bought consignments' do
      post '/api/graphql', params: { query: query }, headers: headers

      expect(response.status).to eq 200
      body = JSON.parse(response.body)

      total_count = body.dig('data', 'consignments', 'totalCount')
      state1 = body.dig('data', 'consignments', 'edges', 0, 'node', 'state')
      state2 = body.dig('data', 'consignments', 'edges', 1, 'node', 'state')
      state3 = body.dig('data', 'consignments', 'edges', 2, 'node', 'state')
      state4 = body.dig('data', 'consignments', 'edges', 3, 'node', 'state')

      expect(total_count).to eq 4
      expect(state1).to eq 'SOLD'
      expect(state2).to eq 'BOUGHT_IN'
      expect(state3).to eq 'SOLD'
      expect(state4).to eq 'BOUGHT_IN'
    end

    describe 'sorting' do
      let(:query) { <<-GRAPHQL }
        query {
          consignments(#{query_inputs}) {
             totalCount
              edges {
                node {
                  currency
                  id
                  internalID
                  saleDate
                  saleName
                  salePriceCents
                  state
                  submissionID
                  submission {
                    artistId
                    category
                    title
                  }
                }
              }
            }
          }
      GRAPHQL

      context 'without a sort parameter' do
        let(:query_inputs) do
          "gravityPartnerId: \"#{partner.gravity_partner_id}\""
        end

        it 'returns the consignments sorted ascending by the id column' do
          post '/api/graphql', params: { query: query }, headers: headers

          expect(response.status).to eq 200
          body = JSON.parse(response.body)

          edges = body.dig('data', 'consignments', 'edges')
          ids = edges.map { |edge| edge.dig('node', 'id') }

          expect(ids).to eq %w[5 4 2 1]
        end
      end

      context 'with a valid sort column' do
        let(:query_inputs) do
          "gravityPartnerId: \"#{
            partner.gravity_partner_id
          }\", sort: CREATED_AT_ASC"
        end

        it 'returns the consignments sorted ascending by created at column' do
          post '/api/graphql', params: { query: query }, headers: headers

          expect(response.status).to eq 200
          body = JSON.parse(response.body)

          edges = body.dig('data', 'consignments', 'edges')
          ids = edges.map { |edge| edge.dig('node', 'id') }
          expect(ids).to eq %w[1 2 4 5]
        end
      end

      context 'with a descending direction prefix' do
        let(:query_inputs) do
          "gravityPartnerId: \"#{
            partner.gravity_partner_id
          }\", sort: CREATED_AT_DESC"
        end

        it 'returns the consignments sorted descending by created at column' do
          post '/api/graphql', params: { query: query }, headers: headers

          expect(response.status).to eq 200
          body = JSON.parse(response.body)

          edges = body.dig('data', 'consignments', 'edges')
          ids = edges.map { |edge| edge.dig('node', 'id') }
          expect(ids).to eq %w[5 4 2 1]
        end
      end
    end
  end
end
