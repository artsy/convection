require 'rails_helper'

describe Admin::PartnersController, type: :controller do
  describe 'with some partners' do
    let(:partners) { Array.new(5) { Fabricate(:partner) } }
    let(:gravql_partners_response) do
      {
        data: {
          partners: partners.map { |p, idx| { id: p.gravity_partner_id, given_name: "p_#{idx}" } }
        }
      }
    end
    let(:xapp_token) { 'xapp_token' }
    let(:gravql_stub) do
      stub_request(:post, 'http://gravity.biz/api/graphql')
        .to_return(body: gravql_partners_response.to_json)
        .with(
          headers: {
            'X-XAPP-TOKEN' => xapp_token,
            'Content-Type' => 'application/json'
          }
        )
    end

    before do
      allow(Convection.config).to receive_messages(gravity_xapp_token: xapp_token, gravity_api_url: 'http://gravity.biz/api')
      allow_any_instance_of(Admin::PartnersController).to receive(:require_artsy_authentication)
    end

    describe '#index' do
      before do
        gravql_stub
      end
      context 'with successful partner details request' do
        it 'returns the first two partners on the first page' do
          get :index, params: { page: 1, size: 2 }
          expect(assigns(:partners).count).to eq 2
        end
        it 'paginates correctly' do
          get :index, params: { page: 3, size: 2 }
          expect(assigns(:partners).count).to eq 1
        end
        it 'returns an alphabetized list of details' do
          gravql_partners_response = {
            data: {
              partners: [
                { id: partners[0].gravity_partner_id, given_name: 'Zenith' },
                { id: partners[1].gravity_partner_id, given_name: 'apples' },
                { id: partners[2].gravity_partner_id, given_name: 'Bananas' },
                { id: partners[3].gravity_partner_id, given_name: 'Leaf' },
                { id: partners[4].gravity_partner_id, given_name: 'cups' }
              ]
            }
          }
          stub_request(:post, 'http://gravity.biz/api/graphql')
            .to_return(body: gravql_partners_response.to_json)
            .with(
              headers: {
                'X-XAPP-TOKEN' => xapp_token,
                'Content-Type' => 'application/json'
              }
            )

          get :index
          expect(
            assigns(:partner_details).map(&:last).pluck(:given_name)
          ).to eq(%w(apples Bananas cups Leaf Zenith))
        end
      end

      context 'with errors in partner details response' do
        let(:gravql_partners_response) do
          {
            data: {
              partners: partners.map { |p, idx| { id: p.gravity_partner_id, given_name: "p_#{idx}" } }
            },
            errors: [
              {
                message: "Can't access subscription_state",
                locations: [
                  {
                    line: 6,
                    column: 5
                  }
                ],
                path: ['partners', 0, 'subscription_state']
              }
            ]
          }
        end

        it 'renders flash error' do
          get :index, params: { page: 1, size: 2 }
          expect(flash[:error]).to eq 'Error fetching some partner details.'
        end
      end
    end
  end
end
