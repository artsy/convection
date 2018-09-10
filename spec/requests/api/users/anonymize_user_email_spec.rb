require 'rails_helper'
require 'support/gravity_helper'

describe 'Anonymize user email' do
  let!(:user1) { Fabricate(:user, email: "test1@test.com") }
  let!(:user2) { Fabricate(:user, email: "test2@test.com") }
  let!(:user3) { Fabricate(:user, email: "test2@test.com") }
  let(:jwt_token) { JWT.encode({ aud: 'gravity' }, Convection.config.jwt_secret) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  it 'finds users with this email address and nils it out' do
    expect(User.where(email: "test1@test.com").count).to eq(1)
    put '/api/anonymize_user_email?email=test1@test.com',
      headers: headers

    expect(User.where(email: "test1@test.com").count).to eq(0)
    expect(user1.reload.email).to be_nil
    expect(response.status).to eq(201)
  end

  it 'works when multiple users are returned' do
    expect(User.where(email: "test2@test.com").count).to eq(2)
    put '/api/anonymize_user_email?email=test2@test.com',
      headers: headers

    expect(User.where(email: "test2@test.com").count).to eq(0)
    expect(user2.reload.email).to be_nil
    expect(user3.reload.email).to be_nil
    expect(response.status).to eq(201)
  end

  it 'does not error out when no users are found' do
    expect(User.where(email: "test3@test.com").count).to eq(0)
    put '/api/anonymize_user_email?email=test3@test.com',
      headers: headers

    expect(response.status).to eq(201)
  end

  it 'requires a decodable token' do
    put '/api/anonymize_user_email',
      params: { email: 'foo@bar.com' },
      headers: { 'Authorization' => 'Bearer foo.bar.baz' }
    expect(response.status).to eq 401
  end

  it 'requires its token to specify a trusted app' do
    bad_token = JWT.encode({ whatever: 'random'}, Convection.config.jwt_secret)

    put '/api/anonymize_user_email', headers: { 'Authorization' => "Bearer #{bad_token}" }
    expect(response.status).to eq 401
  end
end