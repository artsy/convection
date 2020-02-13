# frozen_string_literal: true

require 'rails_helper'

describe 'Submission Index' do
  describe 'GET /' do
    it 'returns the basic index page' do
      allow(ArtsyAdminAuth).to receive(:valid?).and_return(true)
      get '/'
      expect(response.status).to eq 301
      expect(response).to redirect_to '/admin'
    end
  end
end
