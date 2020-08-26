# frozen_string_literal: true

require 'rails_helper'

describe 'offers query' do
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

  let(:query_inputs) { "gravityPartnerId: \"#{partner.gravity_partner_id}\"" }

  let(:query) do
    <<-GRAPHQL
    query {
      offers(#{query_inputs}) {
        edges {
          node {
            id
            commissionPercentWhole
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

        offers_response = body['data']['offers']
        expect(offers_response).to eq nil

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

        offers_response = body['data']['offers']
        expect(offers_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq "Can't find partner."
      end
    end
  end

  describe 'valid requests' do
    context 'with a request from a partner' do
      it 'returns those offers' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        edges = body.dig('data', 'offers', 'edges')
        expect(edges.count).to eq 1
      end
    end

    context 'when asking for only sent offers' do
      let(:consigned_partner_submission) do
        Fabricate :partner_submission, partner: partner
      end
      let!(:accepted_offer) do
        Fabricate :offer,
                  partner_submission: consigned_partner_submission,
                  state: 'accepted'
      end

      let(:query_inputs) do
        "gravityPartnerId: \"#{
          partner.gravity_partner_id
        }\", states: [\"sent\"]"
      end

      it 'returns only the sent offers' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        edges = body.dig('data', 'offers', 'edges')
        expect(edges.count).to eq 1
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
          offers(#{query_inputs}) {
            edges {
              node {
                id
                createdAt
              }
            }
          }
        }
        GRAPHQL
      end

      context 'without a sort column' do
        let(:query_inputs) do
          "gravityPartnerId: \"#{partner.gravity_partner_id}\", sort: null"
        end

        it 'returns the offers sorted ascending by the id column' do
          post '/api/graphql', params: { query: query }, headers: headers

          expect(response.status).to eq 200
          body = JSON.parse(response.body)

          edges = body.dig('data', 'offers', 'edges')
          ids = edges.map { |edge| edge.dig('node', 'id') }
          expect(ids).to eq %w[9 8 7]
        end
      end

      context 'with a valid sort column' do
        let(:query_inputs) do
          "gravityPartnerId: \"#{
            partner.gravity_partner_id
          }\", sort: CREATED_AT_ASC"
        end

        it 'returns the offers sorted ascending by that column' do
          post '/api/graphql', params: { query: query }, headers: headers

          expect(response.status).to eq 200
          body = JSON.parse(response.body)

          edges = body.dig('data', 'offers', 'edges')
          ids = edges.map { |edge| edge.dig('node', 'id') }
          expect(ids).to eq %w[8 9 7]
        end
      end

      context 'with a descending direction prefix' do
        let(:query_inputs) do
          "gravityPartnerId: \"#{
            partner.gravity_partner_id
          }\", sort: CREATED_AT_DESC"
        end

        it 'returns the offers sorted descending by that column' do
          post '/api/graphql', params: { query: query }, headers: headers

          expect(response.status).to eq 200
          body = JSON.parse(response.body)

          edges = body.dig('data', 'offers', 'edges')
          ids = edges.map { |edge| edge.dig('node', 'id') }
          expect(ids).to eq %w[7 9 8]
        end
      end
    end
  end
end
