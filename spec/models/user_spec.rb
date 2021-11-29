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

  context 'active record validation' do
    context 'contact information has not been provided' do
      let(:user) { Fabricate(:user, name: nil, email: nil, phone: nil) }
      it 'fails if gravity_user_id is nil' do
        user.gravity_user_id = nil
        user.validate
        expect(user.errors[:gravity_user_id]).to include("can't be blank")
      end
      it 'fails if gravity_user_id is empty' do
        user.gravity_user_id = ''
        user.validate
        expect(user.errors[:gravity_user_id]).to include("can't be blank")
      end
      it 'passes if gravity_user_id has a value' do
        user.gravity_user_id = 'user-1'
        user.validate
        expect(user.errors[:gravity_user_id]).to_not include("can't be blank")
      end
    end
    context 'contact information has been provided' do
      let(:user) do
        Fabricate(
          :user,
          name: 'user',
          email: 'user@example.com',
          phone: '+1 (212) 555-5555'
        )
      end
      it 'passes if gravity_user_id is nil' do
        user.gravity_user_id = nil
        user.validate
        expect(user.errors[:gravity_user_id]).to_not include("can't be blank")
      end
      it 'passes if gravity_user_id is empty' do
        user.gravity_user_id = ''
        user.validate
        expect(user.errors[:gravity_user_id]).to_not include("can't be blank")
      end
    end
  end

  context 'contact_information?' do
    let(:user) do
      Fabricate(
        :user,
        name: 'user',
        email: 'user@example.com',
        phone: '+1 (212) 555-5555'
      )
    end

    it 'returns true if name, email, and phone have values' do
      expect(user.contact_information?).to be true
    end
    it 'returns false if name is nil' do
      user.name = nil
      expect(user.contact_information?).to be false
    end
    it 'returns false if email is nil' do
      user.name = nil
      expect(user.contact_information?).to be false
    end
    it 'returns false if phone is nil' do
      user.name = nil
      expect(user.contact_information?).to be false
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
      stub_request(
        :get,
        "#{Convection.config.gravity_api_url}/user_details/#{
          user.gravity_user_id
        }"
      ).to_raise(Faraday::ResourceNotFound)
      expect(user.name).to eq 'Buster Bluth'
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
      expect(user.name).to eq 'Buster Bluth'
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
      expect(user.email).to eq 'convection_email'
      expect(user.name).to eq 'convection_name'
      expect(user.phone).to eq 'convection_phone'
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
      expect(user.email).to eq 'buster@bluth.com'
      expect(user.name).to eq 'Buster Bluth'
      expect(user.phone).to eq 'phone'
    end
  end
end
