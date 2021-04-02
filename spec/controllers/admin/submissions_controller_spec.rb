# frozen_string_literal: true

require 'rails_helper'

describe Admin::SubmissionsController, type: :controller do
  describe 'with some submisisons' do
    before do
      allow_any_instance_of(Admin::SubmissionsController).to receive(
        :require_artsy_authentication
      )
      allow(Convection.config).to receive(:gravity_xapp_token).and_return(
        'xapp_token'
      )
      gravql_artists_response = {
        data: {
          artists: [
            { id: 'artist1', name: 'Andy Warhol' },
            { id: 'artist2', name: 'Kara Walker' }
          ]
        }
      }
      stub_request(:post, "#{Convection.config.gravity_api_url}/graphql")
        .to_return(body: gravql_artists_response.to_json).with(
        headers: {
          'X-XAPP-TOKEN' => 'xapp_token', 'Content-Type' => 'application/json'
        }
      )
    end

    context 'with many submissions' do
      before do
        @artist = {id: 'artistId', name: 'Banksy'}
        @user1 = Fabricate(:user, email: 'sarah@artsymail.com')
        @user2 = Fabricate(:user, email: 'lucille@bluth.com')
        @submission1 =
          Fabricate(
            :submission,
            state: 'submitted', title: 'hi hi', user: @user1, artist_id: 'someArtistId'
          )
        @submission2 =
          Fabricate(
            :submission,
            state: 'submitted', title: 'my artwork', user: @user1, artist_id: @artist[:id]
          )
        @submission3 =
          Fabricate(
            :submission,
            state: 'submitted', title: 'another artwork', user: @user2, artist_id: @artist[:id]
          )
        @submission4 =
          Fabricate(:submission, state: 'approved', title: 'zzz', user: @user2)
        @submission5 =
          Fabricate(:submission, state: 'approved', title: 'aaa', user: @user2)
        @deleted_submission =
          Fabricate(
            :submission,
            state: 'submitted',
            title: 'deleted submission',
            user: @user2,
            deleted_at: Time.now.utc
          )
      end

      it 'does not return deleted submissions' do
        get :index
        expect(controller.submissions.count).to eq 5
        expect(controller.submissions).not_to include(@deleted_submission)
      end

      describe 'filtering the index view' do
        it 'returns the first two submissions on the first page' do
          get :index, params: { page: 1, size: 2 }
          expect(controller.submissions.count).to eq 2
        end
        it 'paginates correctly' do
          get :index, params: { page: 3, size: 2 }
          expect(controller.submissions.count).to eq 1
        end
        it 'sets the artist details correctly' do
          get :index
          expect(controller.artist_details).to eq(
            'artist1' => 'Andy Warhol', 'artist2' => 'Kara Walker'
          )
        end
      end

      describe '#sorting and filtering' do
        it 'allows you to filter by state = approved' do
          get :index, params: { state: 'approved' }
          expect(controller.submissions.pluck(:id)).to eq [
               @submission5.id,
               @submission4.id
             ]
        end

        it 'allows you to filter by state = submitted' do
          get :index, params: { state: 'submitted' }
          expect(controller.submissions.pluck(:id)).to eq [
               @submission3.id,
               @submission2.id,
               @submission1.id
             ]
        end

        it 'allows you to sort by user email' do
          get :index, params: { sort: 'users.email', direction: 'asc' }
          expect(controller.submissions.pluck(:id)).to eq(
            [
              @submission5.id,
              @submission4.id,
              @submission3.id,
              @submission2.id,
              @submission1.id
            ]
          )
        end

        it 'allows you to sort by offers_count' do
          Fabricate(
            :offer,
            partner_submission:
              Fabricate(:partner_submission, submission: @submission2)
          )
          Fabricate(
            :offer,
            partner_submission:
              Fabricate(:partner_submission, submission: @submission2)
          )
          Fabricate(
            :offer,
            partner_submission:
              Fabricate(:partner_submission, submission: @submission3)
          )
          get :index, params: { sort: 'offers_count', direction: 'desc' }
          expect(controller.submissions.pluck(:id)).to eq(
            [
              @submission2.id,
              @submission3.id,
              @submission1.id,
              @submission4.id,
              @submission5.id
            ]
          )
        end

        it 'allows you to filter by state and sort by user email' do
          get :index,
              params: {
                sort: 'users.email', direction: 'desc', state: 'submitted'
              }
          expect(controller.submissions.pluck(:id)).to eq [
               @submission2.id,
               @submission1.id,
               @submission3.id
             ]
        end

        it 'allows you to filter by state, search for artist, and sort by ID' do
          get :index,
              params: {
                sort: 'id',
                direction: 'desc',
                state: 'submitted',
                artist: @artist[:id]
              }
          expect(controller.submissions.pluck(:id)).to eq [
               @submission3.id,
               @submission2.id
             ]
        end

        it 'allows you to filter by state, search for user, and sort by ID' do
          get :index,
              params: {
                sort: 'id',
                direction: 'desc',
                state: 'submitted',
                user: @user1.id
              }
          expect(controller.submissions.pluck(:id)).to eq [
               @submission2.id,
               @submission1.id
             ]
        end
      end

      describe 'matching on the index' do
        it 'returns the submissions that match as json' do
          get :index, format: 'json', params: { term: 'hi' }
          submissions = JSON.parse(response.body)
          expect(submissions.length).to eq 1
          expect(submissions.first['id']).to eq @submission1.id
          expect(submissions.first['thumbnail']).to eq nil
        end

        it 'returns multiple submissions that match' do
          get :index, format: 'json', params: { term: 'art' }
          submissions = JSON.parse(response.body)
          expect(submissions.length).to eq 2
          expect(submissions.map { |sub| sub['id'] }).to eq [
               @submission3.id,
               @submission2.id
             ]
        end

        it 'merges in the thumbnail url' do
          Fabricate(
            :image,
            submission: @submission1,
            image_urls: {
              square: 'https://square.jpg', thumbnail: 'https://thumbnail-1.jpg'
            }
          )

          get :index, format: 'json', params: { term: 'hi' }
          submissions = JSON.parse(response.body)
          expect(submissions.length).to eq 1
          expect(submissions.first['id']).to eq @submission1.id
          expect(submissions.first['thumbnail']).to eq 'https://thumbnail-1.jpg'
        end
      end
    end
  end
end
