require 'rails_helper'

describe Admin::UsersController, type: :controller do
  describe 'with some users' do
    before do
      allow_any_instance_of(Admin::UsersController).to receive(:require_artsy_authentication)
    end

    describe '#index' do
      before do
        Fabricate(:user, email: 'sarah@sarah.com')
        Fabricate(:user, email: 'percy@percy.com')
        Fabricate(:user, email: 'lucille@bluth.com')
        Fabricate(:user, email: 'sarah@test.com')
        Fabricate(:user, email: 'test@test.com')
      end

      it 'returns the first two users on the first page' do
        get :index, params: { page: 1, size: 2, format: 'json' }
        expect(controller.users.count).to eq 2
      end

      it 'paginates correctly' do
        get :index, params: { page: 3, size: 2, format: 'json' }
        expect(controller.users.count).to eq 1
      end

      it 'matches on the user email' do
        get :index, params: { term: 'sarah', format: 'json' }
        expect(controller.users.count).to eq 2
        expect(controller.users.pluck(:email)).to include('sarah@test.com', 'sarah@sarah.com')
      end
    end
  end
end
