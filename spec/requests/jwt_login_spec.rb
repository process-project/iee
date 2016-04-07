require 'rails_helper'

RSpec.describe 'JWT' do
  it 'is used to check permissions' do
    user = create(:approved_user)
    resource = create(:resource)
    create(:permission, user: user, resource: resource,
           action: create(:action, name: 'get'))
    auth_headers = { 'Authorization' => "Bearer #{user.token}" }

    get pdp_index_path, { uri: resource.uri, permission: 'get' }, auth_headers

    expect(response.status).to eq(200)
  end
end
