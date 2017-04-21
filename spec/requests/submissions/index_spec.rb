require 'rails_helper'

describe 'Submission Index', type: :request do
  describe 'GET /' do
    it 'returns the basic index page' do
      allow_any_instance_of(ApplicationController).to(
        receive(:require_artsy_authentication)
      )
      get '/'
      expect(response.status).to eq 200
      expect(response.body).to include('Welcome to Convection')
    end
  end
end
