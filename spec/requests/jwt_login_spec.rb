require 'rails_helper'

RSpec.describe 'JWT' do
  let(:user) { create(:approved_user) }
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
end
