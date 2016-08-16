# frozen_string_literal: true
require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe 'Policy entities API' do
  before do
    create(:service, uri: 'https://service.host.com', token: 'random_token')
    @user = create(:user, email: 'user@host.com', approved: true)
    @group = create(:group, name: 'group_name')
    @access_method = create(:access_method, name: 'get')
    @auth_headers = {
      'X-SERVICE-TOKEN' => 'random_token',
      'Authorization' => "Bearer #{@user.token}"
    }
  end

  it 'should return a JSON object with policy entities' do
    get api_policy_entities_path, headers: @auth_headers

    expect(response.status).to eq(200)
    expect(response_json).to include_json(
      policy_entities: [
        { type: 'user_entity', name: @user.email },
        { type: 'group_entity', name: @group.name },
        { type: 'access_method_entity', name: @access_method.name }
      ]
    )
  end

  private

  def response_json
    JSON.parse(response.body)
  end
end
