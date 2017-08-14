require 'rails_helper'

describe Admin::PartnersController, type: :controller do
  describe 'with some partners' do
    before do
      allow_any_instance_of(Admin::PartnersController).to receive(:require_artsy_authentication)
    end
    describe '#index' do
      before do
        5.times { Fabricate(:partner) }
      end
      it 'returns the first two partners on the first page' do
        get :index, params: { page: 1, size: 2 }
        expect(assigns(:partners).count).to eq 2
      end
      it 'paginates correctly' do
        get :index, params: { page: 3, size: 2 }
        expect(assigns(:partners).count).to eq 1
      end
    end
  end
end
