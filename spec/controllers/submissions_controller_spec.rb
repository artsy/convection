require 'rails_helper'

describe Admin::SubmissionsController, type: :controller do
  describe 'with some submisisons' do
    before do
      allow_any_instance_of(Admin::SubmissionsController).to receive(:require_artsy_authentication)
    end
    context 'filtering the index view' do
      before do
        5.times { Submission.create! }
      end
      it 'returns the first two submissions on the first page' do
        get :index, params: { page: 1, size: 2 }
        expect(assigns(:submissions).count).to eq 2
      end
      it 'paginates correctly' do
        get :index, params: { page: 3, size: 2 }
        expect(assigns(:submissions).count).to eq 1
      end
    end
  end
end
