# frozen_string_literal: true

require 'rails_helper'

describe 'consignments query' do
  let(:partner) { Fabricate :partner }
   let!(:consignment_1) {
    Fabricate(
      :partner_submission,
      state: 'bought in',
      partner: partner,
    )
   }

   let!(:consignment_2) {
    Fabricate(
      :partner_submission,
      state: 'sold',
      partner: partner,
    )
   }

   let!(:consignment_3) {
    Fabricate(
      :partner_submission,
      state: 'open',
      partner: partner,
    )
   }

  let(:token) do
    JWT.encode(
      { aud: 'gravity', sub: 'userid', roles: 'partner' },
      Convection.config.jwt_secret
    )
  end

  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  let(:query_inputs) { "gravityPartnerId: \"#{partner.gravity_partner_id}\"" }
  let(:query) do
    <<-GRAPHQL
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
  end

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
    context 'with a request from a partner' do
      it 'returns the expected graphql response' do
        post '/api/graphql', params: { query: query }, headers: headers
        
        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        expect(body['data']).to eq(
          {
            consignments: {
              totalCount: 2,
              edges: [
                {
                  node: {
                    currency: "USD",
                    state: "SOLD",
                  }
                },
                {
                  node: {
                    currency: "USD",
                    state: "BOUGHT_IN",
                  }
                }
              ]
            }
          }.deep_stringify_keys
        )


      end
      it 'returns only returns sold or bought in consignments' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        total_count = body.dig('data', 'consignments', 'totalCount')
        state1 = body.dig('data', 'consignments', 'edges', 0, 'node', 'state')
        state2 = body.dig('data', 'consignments', 'edges', 1, 'node', 'state')

        expect(total_count).to eq 2

        expect(state1). not_to eq 'OPEN'
        expect(state1). not_to eq 'CANCELLED'
        expect(state1). to eq 'SOLD'

        expect(state2). not_to eq 'OPEN'
        expect(state2). not_to eq 'CANCELLED'
        expect(state2). to eq 'BOUGHT_IN'
      end
    end

    context 'when asking for only sent consignments' do
      let(:consigned_partner_submission) do
        Fabricate :partner_submission, partner: partner
      end
      let!(:consigned_offer) do
        Fabricate :offer,
                  partner_submission: consigned_partner_submission,
                  state: 'consigned'
      end

      let(:query_inputs) do
        "gravityPartnerId: \"#{
          partner.gravity_partner_id
        }\""
      end

      it 'returns only the requested consignments' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        total = body.dig('data', 'consignments', 'totalCount')

        expect(total).to eq 2
      end
    end

    describe 'sorting' do
      let!(:offer) do
        ps = Fabricate :partner_submission, partner: partner
        Fabricate :offer, partner_submission: ps, id: 7, created_at: 1.day.ago
      end
      let!(:middle_offer) do
        ps = Fabricate :partner_submission, partner: partner
        Fabricate :offer, partner_submission: ps, id: 8, created_at: 3.days.ago
      end
      let!(:last_offer) do
        ps = Fabricate :partner_submission, partner: partner
        Fabricate :offer, partner_submission: ps, id: 9, created_at: 2.days.ago
      end

      let(:query) do
        <<-GRAPHQL
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
      end

      context 'without a sort column' do
        let(:query_inputs) do
          "gravityPartnerId: \"#{
            partner.gravity_partner_id
          }\""
        end
        it 'returns the consignments sorted ascending by the id column' do
          post '/api/graphql', params: { query: query }, headers: headers

          expect(response.status).to eq 200
          body = JSON.parse(response.body)

          edges = body.dig('data', 'consignments', 'edges')
          ids = edges.map { |edge| edge.dig('node', 'id') }


          expect(ids).to eq %w[2 1]
        end
      end

      context 'with a valid sort column' do
        let(:query_inputs) do
          "gravityPartnerId: \"#{
            partner.gravity_partner_id
          }\", sort: CREATED_AT_ASC"
        end

        it 'returns the consignments sorted ascending by that column' do
          post '/api/graphql', params: { query: query }, headers: headers

          expect(response.status).to eq 200
          body = JSON.parse(response.body)

          edges = body.dig('data', 'consignments', 'edges')
          ids = edges.map { |edge| edge.dig('node', 'id') }
          expect(ids).to eq %w[1 2]
        end
      end

      context 'with a descending direction prefix' do
        let(:query_inputs) do
          "gravityPartnerId: \"#{
            partner.gravity_partner_id
          }\", sort: CREATED_AT_DESC"
        end

        it 'returns the consignments sorted descending by that column' do
          post '/api/graphql', params: { query: query }, headers: headers

          expect(response.status).to eq 200
          body = JSON.parse(response.body)

          edges = body.dig('data', 'consignments', 'edges')
          ids = edges.map { |edge| edge.dig('node', 'id') }
          expect(ids).to eq %w[2 1]
        end
      end
    end
  end
end
