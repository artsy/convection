require 'rails_helper'

describe Admin::PartnersController, type: :controller do
  describe 'with some partners' do
    let!(:partner1) { Fabricate(:partner, name: 'zz top') }
    let!(:partner2) { Fabricate(:partner, name: 'abracadabra') }
    let!(:partner3) { Fabricate(:partner, name: 'animal prints') }
    let!(:partner4) { Fabricate(:partner, name: 'bubbles') }
    let!(:partner5) { Fabricate(:partner, name: 'gagosian') }

    before do
      allow_any_instance_of(Admin::PartnersController).to receive(:require_artsy_authentication)
    end

    describe '#index' do
      context 'with successful partner details request' do
        it 'returns the first two partners on the first page' do
          get :index, params: { page: 1, size: 2 }
          expect(assigns(:partners).count).to eq 2
        end
        it 'paginates correctly' do
          get :index, params: { page: 3, size: 2 }
          expect(assigns(:partners).count).to eq 1
        end
        it 'orders the partners correctly' do
          get :index, params: { page: 1 }
          expect(assigns(:partners).count).to eq 5
          expect(assigns(:partners).map(&:name)).to eq(['abracadabra', 'animal prints', 'bubbles', 'gagosian', 'zz top'])
        end
      end
    end
  end
end
