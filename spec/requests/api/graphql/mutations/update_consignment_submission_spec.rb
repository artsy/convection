# frozen_string_literal: true

require 'rails_helper'

describe 'updateConsignmentSubmission mutation' do
  let(:user) { Fabricate(:user, gravity_user_id: 'userid') }
  let(:submission) do
    attrs = {
      artist_id: 'abbas-kiarostami',
      category: 'Painting',
      state: 'submitted',
      title: 'rain',
      user: user
    }

    Fabricate(:submission, attrs)
  end

  let(:token) do
    payload = { aud: 'gravity', sub: user.gravity_user_id, roles: 'user' }
    JWT.encode(payload, Convection.config.jwt_secret)
  end

  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  let(:mutation_inputs) do
    "{ state: DRAFT, category: JEWELRY, clientMutationId: \"test\", id: #{
      submission.id
    }, artistId: \"andy-warhol\", title: \"soup\" }"
  end

  let(:mutation) do
    <<-GRAPHQL
    mutation {
      updateConsignmentSubmission(input: #{mutation_inputs}){
        clientMutationId
        consignmentSubmission {
          category
          state
          id
          artistId
          title
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

        update_response = body['data']['updateConsignmentSubmission']
        expect(update_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq "Can't access updateConsignmentSubmission"
      end
    end

    context 'with a request missing an app token' do
      let(:token) do
        payload = { sub: 'userid', roles: 'user' }
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        update_response = body['data']['updateConsignmentSubmission']
        expect(update_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq "Can't access updateConsignmentSubmission"
      end
    end

    context 'with a request updating a submission that you do not own' do
      let(:token) do
        payload = { aud: 'gravity', sub: 'userid2', roles: 'user' }
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        update_response = body['data']['updateConsignmentSubmission']
        expect(update_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq 'Submission Not Found'
      end
    end

    context 'with an invalid submission id' do
      let(:mutation_inputs) do
        '{ clientMutationId: "test", id: 999999, artistId: "andy-warhol", title: "soup" }'
      end

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        update_response = body['data']['updateConsignmentSubmission']
        expect(update_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq 'Submission from ID Not Found'
      end
    end

    describe 'valid requests' do
      it 'updates the submission' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submission_response =
          body['data']['updateConsignmentSubmission']['consignmentSubmission']
        expect(submission_response).to include(
          {
            'id' => submission.id.to_s,
            'title' => 'soup',
            'artistId' => 'andy-warhol',
            'category' => 'JEWELRY',
            'state' => 'DRAFT'
          }
        )
      end
    end
  end
end
