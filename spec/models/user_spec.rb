# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe User do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { Fabricate(:user, gravity_user_id: 'userid') }

  it 'generates a consistent consignor number' do
    travel_to Time.zone.local(2_019, 1, 1, 0, 0, 0) do
      user.id = 1
      expect(user.unique_code_for_digest).to eq(801)
      user.id = 9
      expect(user.unique_code_for_digest).to eq(809)
    end

    travel_to Time.zone.local(2_019, 8, 7, 6, 5, 4) do
      user1 = Fabricate(:user)
      user1.id = 1
      expect(user1.unique_code_for_digest).to eq(57_905)
    end
  end

  context 'gravity_user' do
    it 'returns nil if it cannot find the object' do
      stub_gravity_root
      stub_request(
        :get,
        "#{Convection.config.gravity_api_url}/users/#{user.gravity_user_id}"
      ).to_raise(Faraday::ResourceNotFound)
      expect(user.gravity_user).to be_nil
      expect(user.user_name).to be_nil
    end

    it 'returns the object if it can find it' do
      stub_gravity_root
      stub_gravity_user(id: user.gravity_user_id, name: 'Buster Bluth')
      expect(user.user_name).to eq 'Buster Bluth'
    end
  end

  context 'user detail' do
    it 'returns nil if it cannot find the object' do
      stub_gravity_root
      stub_gravity_user(id: user.gravity_user_id, name: 'Buster Bluth')
      stub_request(
        :get,
        "#{Convection.config.gravity_api_url}/user_details/#{
          user.gravity_user_id
        }"
      ).to_raise(Faraday::ResourceNotFound)
      expect(user.user_name).to eq 'Buster Bluth'
      expect(user.user_detail).to be_nil
      expect(user.user_detail&.email).to be_nil
    end

    it 'returns the object if it can find it' do
      stub_gravity_root
      stub_gravity_user(id: user.gravity_user_id, name: 'Buster Bluth')
      stub_gravity_user_detail(
        id: user.gravity_user_id,
        email: 'buster@bluth.com'
      )
      expect(user.user_name).to eq 'Buster Bluth'
      expect(user.user_detail.email).to eq 'buster@bluth.com'
    end

    it 'returns nil if there is no gravity_user' do
      stub_gravity_root
      stub_request(
        :get,
        "#{Convection.config.gravity_api_url}/users/#{user.gravity_user_id}"
      ).to_raise(Faraday::ResourceNotFound)
      expect(user.user_detail).to be_nil
    end
  end

  context 'user info already in convection db' do
    let(:user) do
      Fabricate(
        :user,
        gravity_user_id: 'userid',
        email: 'convection_email',
        name: 'convection_name',
        phone: 'convection_phone'
      )
    end

    before do
      stub_gravity_root
      stub_gravity_user(id: user.gravity_user_id, name: 'Buster Bluth')
      stub_gravity_user_detail(
        id: user.gravity_user_id,
        email: 'buster@bluth.com'
      )
      user
    end

    it 'return info from convection' do
      expect(user.user_email).to eq 'convection_email'
      expect(user.user_name).to eq 'convection_name'
      expect(user.user_phone).to eq 'convection_phone'
    end
  end

  context 'user info does not exist in convection db' do
    let(:user) { Fabricate(:user, gravity_user_id: 'userid', email: nil) }

    before do
      stub_gravity_root
      stub_gravity_user(id: user.gravity_user_id, name: 'Buster Bluth')
      stub_gravity_user_detail(
        id: user.gravity_user_id,
        email: 'buster@bluth.com',
        phone: 'phone'
      )
      user
    end

    it 'return info from gravity' do
      expect(user.user_email).to eq 'buster@bluth.com'
      expect(user.user_name).to eq 'Buster Bluth'
      expect(user.user_phone).to eq 'phone'
    end
  end
end
