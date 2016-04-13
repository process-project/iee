require 'rails_helper'

RSpec.describe 'JWT' do
  let(:user) do
    create(:approved_user,
           password: 'asdfgh123',
           password_confirmation: 'asdfgh123')
  end
  let(:auth_headers) { { 'Authorization' => "Bearer #{user.token}" } }

  it 'is used to login into API endpoitns' do
    resource = create(:resource)
    create(:permission, user: user, resource: resource,
           action: create(:action, name: 'get'))

    get api_pdp_index_path,
        { uri: resource.uri, permission: 'get' },
        auth_headers

    expect(response.status).to eq(200)
  end

  it 'is not permitted to be used to enter UI' do
    get help_path, nil, auth_headers

    expect(response.status).to_not eq(200)
  end

  it 'can be retrieved using API login' do
    post api_sessions_path,
         { user: { email: user.email, password: user.password } }

    expect(response.status).to eq(201)
    expect(User.from_token(user_details['token']).id).to eq(user.id)
    expect(user_details['name']).to eq(user.name)
    expect(user_details['email']).to eq(user.email)
  end

  it 'can be retrieved only when valid credentials are given' do
    post api_sessions_path,
      { user: { email: user.email, password: 'bad password' } }

    expect(response.status).to eq(401)
  end

  def user_details
    JSON.parse(response.body)['user']
  end
end
