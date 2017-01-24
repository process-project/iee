# frozen_string_literal: true
require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe 'Policy entities API' do
  include JsonHelpers

  it 'should return a JSON object with policy entities' do
    create(:service, uri: 'https://service.host.com', token: 'random_token')
    group = create(:group, name: 'group_name')
    access_method = create(:access_method, name: 'get')
    auth_headers = {
      'X-SERVICE-TOKEN' => 'random_token',
      'Authorization' => "Bearer #{group.users.first.token}"
    }

    get api_policy_entities_path, headers: auth_headers

    expect(response.status).to eq(200)
    expect(response_json).to include_json(
      policy_entities: [
        { type: 'user_entity', name: group.users.first.email },
        { type: 'group_entity', name: group.name },
        { type: 'access_method_entity', name: access_method.name }
      ]
    )
  end
end
