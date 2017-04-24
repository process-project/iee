# frozen_string_literal: true
require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe 'Policies API' do
  include JsonHelpers

  let(:service) { create(:service, uri: 'https://service.host.com', token: 'random_token') }
  let(:access_method) { create(:access_method, name: 'get') }
  let(:user) { create(:approved_user, email: 'user@host.com') }
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

  it 'should return unauthorized when a copy request on a resources which is not owned is sent' do
    post api_policies_path,
         params: policy_post_params(path: '/another/path', copy_from: resource.path),
         headers: valid_auth_headers,
         as: :json

    expect(response.status).to eq(403)
  end

  it 'should return a single policy with single user and group as managers' do
    group = create(:group, name: 'group_name')
    ResourceManager.create(user: user, resource: resource)
    ResourceManager.create(group: group, resource: resource)

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

  it 'should return a valid response when no path parameter is given' do
    get api_policies_path, headers: valid_auth_headers

    expect(response.status).to eq(200)
    expect(response_json).to include_json(
      policies: []
    )
  end

  it 'should return a bad request status for a path which does not exist' do
    get api_policies_path, params: { path: 'does_not_exist' }, headers: valid_auth_headers

    expect(response.status).to eq(400)
  end

  it 'should return a bad request status if we send a JSON with empty permission array' do
    post api_policies_path,
         params: policy_post_params(path: '/some/path', permissions: []),
         headers: valid_auth_headers,
         as: :json

    expect(response.status).to eq(400)
  end

  it 'should return a bad request when a copy request is sent for existing resource' do
    post api_policies_path,
         params: policy_post_params(path: resource.path, copy_from: '/another/path'),
         headers: valid_auth_headers,
         as: :json

    expect(response.status).to eq(400)
  end

  it 'should return a bad request when a move request is sent for existing resource' do
    post api_policies_path,
         params: policy_post_params(path: resource.path, move_from: '/another/path'),
         headers: valid_auth_headers,
         as: :json

    expect(response.status).to eq(400)
    expect(response.body).to include('Destination resource already exists')
  end

  it 'should return a 201 status code and create a DB resource when valid policy JSON is sent' do
    post  api_policies_path,
          params: policy_post_params(
            path: '/some/path',
            permissions: [{ type: 'user_permission',
                            entity_name: user.email,
                            access_methods: ['get'] }]
          ),
          headers: valid_auth_headers,
          as: :json

    expect(response.status).to eq(201)
    expect(Resource.last.path).to eq('/some/path')
  end

  it 'should return a 201 status code for an access method given in capital letters' do
    post  api_policies_path,
          params: policy_post_params(
            path: '/some/path',
            permissions: [{ type: 'user_permission',
                            entity_name: user.email,
                            access_methods: ['get'] }]
          ),
          headers: valid_auth_headers,
          as: :json

    expect(AccessPolicy.first.access_method.name).to eq('get')
  end

  it 'should create a local resource when valid creation request is sent' do
    post  api_policies_path,
          params: policy_post_params(
            path: '/another/path',
            permissions: [{ type: 'user_permission',
                            entity_name: user.email,
                            access_methods: ['get'] }]
          ),
          headers: valid_auth_headers,
          as: :json

    expect(Resource.last).to be_local
  end

  it 'set current user as resource manager' do
    post  api_policies_path,
          params: policy_post_params(path: '/another/path'),
          headers: valid_auth_headers,
          as: :json
    resource = Resource.last

    expect(resource.resource_managers.where(user: user)).to be_exist
  end

  context 'as resource manager' do
    before do
      ResourceManager.create(user: user, resource: resource)
    end

    it 'should merge the new method of the given policy with an existing one' do
      create(:access_method, name: 'post', service: service)

      post  api_policies_path,
            params: policy_post_params(
              path: resource.path,
              permissions: [{ type: 'user_permission',
                              entity_name: user.email,
                              access_methods: ['post'] }]
            ),
            headers: valid_auth_headers,
            as: :json

      expect(response.status).to eq(200)
      expect(AccessPolicy.last.access_method.name).to eq('post')
    end

    it 'should merge the given user manager of the given policy with an existing one' do
      another_user = create(:approved_user, email: 'another@host.com')

      post  api_policies_path,
            params: policy_post_params(
              path: resource.path,
              managers: { users: [another_user.email] }
            ),
            headers: valid_auth_headers,
            as: :json

      expect(response.status).to eq(200)
      expect(resource.resource_managers.where(user: another_user)).to be_exist
    end

    it 'should merge the given management group of the given policy with an existing one' do
      another_group = create(:group, name: 'another_group')

      post  api_policies_path,
            params: policy_post_params(
              path: resource.path,
              managers: { groups: [another_group.name] }
            ),
            headers: valid_auth_headers,
            as: :json

      expect(response.status).to eq(200)
      expect(resource.resource_managers.where(group: another_group)).to be_exist
    end

    it 'should delete an access policy for a user' do
      another_user = create(:approved_user, email: 'another@host.com')
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

    it 'should delete only an access policy for the given access method leaving the rest intact' do
      post_method = create(:access_method, name: 'post')
      create(:access_policy, user: user, access_method: post_method, resource: resource)

      expect do
        delete  api_policies_path,
                params: {
                  path: resource.path,
                  user: user.email,
                  access_method: post_method.name
                },
                headers: valid_auth_headers
      end.to change { AccessPolicy.count }.by(-1)
      expect(response.status).to eq(204)
      expect(
        AccessPolicy.find_by(resource: resource, user: user, access_method: access_method)
      ).not_to be_nil
    end

    context 'with copy and move operations for a resource with policies' do
      before do
        resource.access_policies.create(user: user, access_method: access_method,
                                        resource: resource)
        create(:resource, service: service, path: resource.path + '/sub')
      end

      it 'should copy the resource and subresource with managers and access policies' do
        post api_policies_path,
             params: policy_post_params(path: '/another/path', copy_from: resource.path),
             headers: valid_auth_headers,
             as: :json

        expect(response.status).to eq(201)
        expect(Resource.find_by(path: resource.path)).to be
        expect(Resource.find_by(path: resource.path + '/sub')).to be
        check_resource_existence('/another/path', '/another/path/sub')
      end

      it 'should move the resource and subresource with managers and access policies' do
        post api_policies_path,
             params: policy_post_params(path: '/another/path', move_from: resource.path),
             headers: valid_auth_headers,
             as: :json

        expect(response.status).to eq(201)
        expect(Resource.find_by(path: resource.path)).to be_nil
        expect(Resource.find_by(path: resource.path + '/sub')).to be_nil
        check_resource_existence('/another/path', '/another/path/sub')
      end
    end
  end

  it 'should return a not found code when source policy is not defined' do
    wildcard_resource = create(:resource, service: service, path: '/a/resource/.*')
    ResourceManager.create(user: user, resource: wildcard_resource)

    post api_policies_path,
         params: policy_post_params(path: '/a/resource/to/*', move_from: '/a/resource/from/*'),
         headers: valid_auth_headers,
         as: :json

    expect(response.status).to eq(404)
    expect(response.body).to include('Source policy does not exist for copying/moving')
  end

  it 'should return a forbidden status when a user is not allowed to manage a given resource' do
    another_user = create(:approved_user, email: 'another@host.com')

    post  api_policies_path,
          params: policy_post_params(path: resource.path),
          headers: valid_auth_headers.merge('Authorization' => "Bearer #{another_user.token}"),
          as: :json

    expect(response.status).to eq(403)
  end

  it 'should return a bad request when no path parameter is given' do
    delete api_policies_path, headers: valid_auth_headers

    expect(response.status).to eq(400)
  end

  it 'should return a bad request when removing a resource with invalid path' do
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

  it 'should return a forbidden status when a user does not own every resource being deleted' do
    another_user = create(:approved_user, email: 'another@host.com')

    delete  api_policies_path,
            params: { path: resource.path },
            headers: valid_auth_headers.merge('Authorization' => "Bearer #{another_user.token}")

    expect(response.status).to eq(403)
  end

  context 'with resources containing wildcards' do
    it 'should save a new policy given with a wildcard with a converted asterisk character' do
      post  api_policies_path,
            params: policy_post_params(
              path: '/another/path/*',
              permissions: [{ type: 'user_permission',
                              entity_name: user.email,
                              access_methods: ['get'] }]
            ),
            headers: valid_auth_headers,
            as: :json

      expect(response.status).to eq(201)
      expect(Resource.last.path).to eq('/another/path/.*')
    end

    context 'for existing wildcard resource' do
      let(:wildcard_resource) do
        create(:resource, pretty_path: '/another/path/*', service: service)
      end

      before do
        ResourceManager.create(user: user, resource: wildcard_resource)
      end

      it 'should be matched with a resource defined with a wildcard regular expression' do
        create(:access_method, name: 'post', service: service)

        post  api_policies_path,
              params: policy_post_params(
                path: '/another/path/*',
                permissions: [{ type: 'user_permission',
                                entity_name: user.email,
                                access_methods: ['post'] }]
              ),
              headers: valid_auth_headers,
              as: :json

        expect(response.status).to eq(200)
        expect(AccessPolicy.last.access_method.name).to eq('post')
      end

      it 'should return a policy with proper wildcard character' do
        create(:access_policy, user: user, access_method: access_method,
                               resource: wildcard_resource)

        get api_policies_path, params: { path: wildcard_resource.pretty_path },
                               headers: valid_auth_headers

        expect(response_json).to include_json(
          policies: [
            {
              path: wildcard_resource.pretty_path,
              managers: {
                users: [user.email],
                groups: []
              },
              permissions: [
                { type: 'user_permission', entity_name: user.email, access_methods: ['get'] }
              ]
            }
          ]
        )
      end

      it 'should delete a selected policy for a resource with a wildcard in the path' do
        create(:access_policy, user: user, access_method: access_method,
                               resource: wildcard_resource)

        delete  api_policies_path,
                params: {
                  path: wildcard_resource.pretty_path,
                  user: user.email,
                  access_method: access_method.name
                },
                headers: valid_auth_headers

        expect(response.status).to eq(204)
        expect(
          AccessPolicy.find_by(resource: wildcard_resource, user: user,
                               access_method: access_method)
        ).to be_nil
      end
    end
  end

  context 'for a second service present' do
    let(:service2) { create(:service, uri: 'https://service2.host.com', token: 'random_token_2') }
    let(:resource2) { create(:resource, service: service2) }

    before do
      create(:access_policy, user: user, access_method: access_method, resource: resource2)
    end

    it 'should return only policies for the first service' do
      get api_policies_path, headers: valid_auth_headers

      expect(response_json).to include_json(
        policies: [{ path: resource.path }]
      )
      expect(response_json).not_to include_json(
        policies: [{ path: resource2.path }]
      )
    end
  end

  def valid_auth_headers
    user_auth_headers.merge(service_auth_header)
  end

  def policy_post_params(path: '', managers: nil, permissions: nil, copy_from: nil, move_from: nil)
    result = {}
    result[:path] = path
    result[:managers] = managers if managers
    result[:permissions] = permissions if permissions
    result[:copy_from] = copy_from if copy_from
    result[:move_from] = move_from if move_from

    result
  end

  def check_resource_existence(path, subpath)
    resource = Resource.find_by(path: path)
    expect(resource).to be
    expect(resource.path).to eq(path)
    check_managers(resource)
    check_access_policies(resource)
    expect(Resource.find_by(path: subpath)).to be
  end

  def check_managers(resource)
    expect(resource.resource_managers.count).to eq(1)
    expect(resource.resource_managers[0].user).to eq(user)
  end

  def check_access_policies(resource)
    check_access_method(resource)
    expect(resource.access_policies.count).to eq(1)
    expect(resource.access_policies[0].user).to eq(user)
  end

  def check_access_method(resource)
    expect(resource.access_policies[0].access_method).to eq(access_method)
  end
end
