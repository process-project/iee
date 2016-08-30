# frozen_string_literal: true
require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe 'Policies API' do
  include JsonHelpers

  let(:service) { create(:service, uri: 'https://service.host.com', token: 'random_token') }
  let(:access_method) { create(:access_method, name: 'get') }
  let(:user) { create(:user, email: 'user@host.com', approved: true) }
  let(:resource) { create(:resource, service: service) }
  let(:service_auth_header) { { 'X-SERVICE-TOKEN' => 'random_token' } }
  let(:user_auth_headers) { { 'Authorization' => "Bearer #{user.token}" } }

  before do
    create(:access_policy, user: user, access_method: access_method, resource: resource)
  end

  it 'should return unauthorized status when no token is provided in the request' do
    post api_policies_path, headers: user_auth_headers

    expect(response.status).to eq(401)
  end

  it 'should return unauthorized status when no user token is provided' do
    post api_policies_path, headers: service_auth_header

    expect(response.status).to eq(401)
  end

  it 'should return a single policy with single user and group as managers' do
    manage_method = create(:access_method, name: 'manage')
    create(:access_policy, user: user, resource: resource, access_method: manage_method)
    group = create(:group, name: 'group_name')
    create(:access_policy, group: group, resource: resource, access_method: manage_method)
    get api_policies_path, params: { path: resource.path }, headers: valid_auth_headers

    expect(response_json).to include_json(
      policies: [
        {
          path: resource.path,
          managers: {
            users: [user.email],
            groups: [group.name]
          },
          permissions: [
            { type: 'user_permission', entity_name: user.email, access_methods: ['get'] }
          ]
        }
      ]
    )
  end

  it `should return a valid response when no path parameter is given` do
    get api_policies_path, headers: valid_auth_headers

    expect(response.status).to eq(200)
    expect(response_json).to include_json(
      policies: []
    )
  end

  it `should return a bad request status for a path which does not exist` do
    get api_policies_path, params: { path: 'does_not_exist' }, headers: valid_auth_headers

    expect(response.status).to eq(400)
  end

  it `should not return the manage role in the response body` do
    manage_method = create(:access_method, name: 'manage')
    create(:access_policy, user: user, resource: resource, access_method: manage_method)

    get api_policies_path, params: { path: resource.path }, headers: valid_auth_headers

    expect(response.status).to eq(200)
    expect(response_json).not_to include_json(
      policies: [
        {
          permissions: [
            { access_methods: ['manage'] }
          ]
        }
      ]
    )
  end

  it 'should return a bad request status if we send a JSON with empty permission array' do
    post api_policies_path,
         params: {
           path: '/some/path',
           managers: {},
           permissions: []
         },
         headers: valid_auth_headers,
         as: :json

    expect(response.status).to eq(400)
  end

  it 'should return a 201 status code and create a DB resource when valid policy JSON is sent' do
    post  api_policies_path,
          params: {
            path: 'some/path',
            managers: {},
            permissions: [
              type: 'user_permission',
              entity_name: user.email,
              access_methods: ['get']
            ]
          },
          headers: valid_auth_headers,
          as: :json

    expect(response.status).to eq(201)
    expect(Resource.last.path).to eq('some/path')
  end

  it 'should return a 201 status code for an access method given in capital letters' do
    post  api_policies_path,
          params: {
            path: '/some/path',
            managers: {},
            permissions: [
              type: 'user_permission',
              entity_name: user.email,
              access_methods: ['get']
            ]
          },
          headers: valid_auth_headers,
          as: :json

    expect(AccessPolicy.first.access_method.name).to eq('get')
  end

  it `should append the manage role for a path which is created` do
    create(:access_method, name: 'manage')

    post  api_policies_path,
          params: { path: '/some/path' },
          headers: valid_auth_headers,
          as: :json

    expect(AccessPolicy.last.access_method.name).to eq('manage')
  end

  context 'with managing permissions' do
    before do
      manage_method = create(:access_method, name: 'manage')
      create(:access_policy, user: user, resource: resource, access_method: manage_method)
    end

    it `should merge the new method of the given policy with an existing one` do
      create(:access_method, name: 'post')

      post  api_policies_path,
            params: {
              path: resource.path,
              managers: {},
              permissions: [
                type: 'user_permission',
                entity_name: user.email,
                access_methods: ['post']
              ]
            },
            headers: valid_auth_headers,
            as: :json

      expect(response.status).to eq(200)
      expect(AccessPolicy.last.access_method.name).to eq('post')
    end

    it `should merge the given user manager of the given policy with an existing one` do
      another_user = create(:user, email: 'another@host.com', approved: true)

      post  api_policies_path,
            params: {
              path: resource.path,
              managers: { users: [another_user.email] }
            },
            headers: valid_auth_headers,
            as: :json

      expect(response.status).to eq(200)
      expect(AccessPolicy.last.user.email).to eq(another_user.email)
      expect(AccessPolicy.last.access_method.name).to eq('manage')
    end

    it `should merge the given management group of the given policy with an existing one` do
      another_group = create(:group, name: 'another_group')

      post  api_policies_path,
            params: {
              path: resource.path,
              managers: { groups: [another_group.name] }
            },
            headers: valid_auth_headers,
            as: :json

      expect(response.status).to eq(200)
      expect(AccessPolicy.last.group.name).to eq(another_group.name)
      expect(AccessPolicy.last.access_method.name).to eq('manage')
    end

    it 'should delete an access policy for a user' do
      another_user = create(:user, email: 'another@host.com', approved: true)
      create(:access_policy, user: another_user, access_method: access_method, resource: resource)

      expect do
        delete  api_policies_path,
                params: {
                  path: resource.path,
                  user: user.email,
                  access_method: access_method.name
                },
                headers: valid_auth_headers
      end.to change { AccessPolicy.count }.by(-1)
      expect(response.status).to eq(204)
      expect(
        AccessPolicy.find_by(resource: resource, user: user, access_method: access_method)
      ).to be_nil
    end
  end

  it `should return a forbidden status when a user is not allowed to manage a given resource` do
    another_user = create(:user, email: 'another@host.com', approved: true)

    post  api_policies_path,
          params: {
            path: resource.path
          },
          headers: valid_auth_headers.merge('Authorization' => "Bearer #{another_user.token}"),
          as: :json

    expect(response.status).to eq(403)
  end

  it `should return a bad request when no path parameter is given` do
    delete api_policies_path, headers: valid_auth_headers

    expect(response.status).to eq(400)
  end

  it `should return a bad request when removing a resource with invalid path` do
    delete api_policies_path, params: { path: 'not_existing_path' }, headers: valid_auth_headers

    expect(response.status).to eq(400)
  end

  it 'should return a bad request when any given user is invalid' do
    delete  api_policies_path,
            params: {
              path: resource.path,
              user: 'hello'
            },
            headers: valid_auth_headers

    expect(response.status).to eq(400)
  end

  it `should return a forbidden status when a user does not own every resource being deleted` do
    another_user = create(:user, email: 'another@host.com', approved: true)

    delete  api_policies_path,
            params: { path: resource.path },
            headers: valid_auth_headers.merge('Authorization' => "Bearer #{another_user.token}")

    expect(response.status).to eq(403)
  end

  def valid_auth_headers
    user_auth_headers.merge(service_auth_header)
  end
end
