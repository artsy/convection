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
    context 'filtering the index view' do
      before do
        5.times { Fabricate(:submission, state: 'submitted') }
      end
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
  end
end
