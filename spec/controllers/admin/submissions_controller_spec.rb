require 'rails_helper'

describe Admin::SubmissionsController, type: :controller do
  describe 'with some submisisons' do
    before do
      allow_any_instance_of(Admin::SubmissionsController).to receive(:require_artsy_authentication)
      allow(Convection.config).to receive(:gravity_xapp_token).and_return('xapp_token')
      gravql_artists_response = {
        data: {
          artists: [
            { id: 'artist1', name: 'Andy Warhol' },
            { id: 'artist2', name: 'Kara Walker' }
          ]
        }
      }
      stub_request(:post, "#{Convection.config.gravity_api_url}/graphql")
        .to_return(body: gravql_artists_response.to_json)
        .with(
          headers: {
            'X-XAPP-TOKEN' => 'xapp_token',
            'Content-Type' => 'application/json'
          }
        )
    end

    context 'with many submissions' do
      before do
        @submission1 = Fabricate(:submission, state: 'submitted', title: 'hi hi')
        @submission2 = Fabricate(:submission, state: 'submitted', title: 'my artwork')
        @submission3 = Fabricate(:submission, state: 'submitted', title: 'another artwork')
        Fabricate(:submission, state: 'submitted', title: 'zzz')
        Fabricate(:submission, state: 'submitted', title: 'aaa')
      end

      describe 'filtering the index view' do
        it 'returns the first two submissions on the first page' do
          get :index, params: { page: 1, size: 2 }
          expect(assigns(:submissions).count).to eq 2
        end
        it 'paginates correctly' do
          get :index, params: { page: 3, size: 2 }
          expect(assigns(:submissions).count).to eq 1
        end
        it 'sets the artist details correctly' do
          get :index
          expect(assigns(:artist_details)).to eq('artist1' => 'Andy Warhol',
                                                 'artist2' => 'Kara Walker')
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
          expect(submissions.map { |sub| sub['id'] }).to eq [@submission2.id, @submission3.id]
        end

        it 'merges in the thumbnail url' do
          Fabricate(:image,
            submission: @submission1,
            image_urls: { square: 'https://square.jpg', thumbnail: 'https://thumbnail-1.jpg' })

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
