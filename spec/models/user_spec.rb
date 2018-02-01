require 'rails_helper'
require 'support/gravity_helper'

describe User do
  let!(:user) { Fabricate(:user, gravity_user_id: 'userid') }

  context 'gravity_user' do
    it 'returns nil if it cannot find the object' do
      stub_gravity_root
      stub_request(:get, "#{Convection.config.gravity_api_url}/users/#{user.gravity_user_id}")
        .to_raise(Faraday::ResourceNotFound)
      expect(user.gravity_user).to be_nil
      expect(user.name).to be_nil
    end

    it 'returns the object if it can find it' do
      stub_gravity_root
      stub_gravity_user(id: user.gravity_user_id, name: 'Buster Bluth')
      expect(user.name).to eq 'Buster Bluth'
    end
  end

  context 'user detail' do
    it 'returns nil if it cannot find the object' do
      stub_gravity_root
      stub_gravity_user(id: user.gravity_user_id, name: 'Buster Bluth')
      stub_request(:get, "#{Convection.config.gravity_api_url}/user_details/#{user.gravity_user_id}")
        .to_raise(Faraday::ResourceNotFound)
      expect(user.name).to eq 'Buster Bluth'
      expect(user.user_detail).to be_nil
      expect(user.user_detail&.email).to be_nil
    end

    it 'returns the object if it can find it' do
      stub_gravity_root
      stub_gravity_user(id: user.gravity_user_id, name: 'Buster Bluth')
      stub_gravity_user_detail(id: user.gravity_user_id, email: 'buster@bluth.com')
      expect(user.name).to eq 'Buster Bluth'
      expect(user.user_detail.email).to eq 'buster@bluth.com'
    end
  end
end
