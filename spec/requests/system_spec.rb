# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe 'System Up Endpoint' do
  describe 'GET up' do
    it 'returns valid JSON indicating the app is alive' do
      get '/system/up'
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['rails']).to eq true
    end
  end
end
