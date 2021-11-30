# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  it 'creates an admin user' do
    Fabricate(:admin_user)

    expect(AdminUser.count).to eq(1)
  end
end
