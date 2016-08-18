# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Resource policies API' do
  before do
    service = create(:service,
                     uri: 'https://service.host.com', token: 'random_token')
    access_method = create(:access_method, name: 'get')
    user = create(:user, email: 'user@host.com', approved: true)
    @resource = create(:resource, service: service)
    create(:access_policy,
           user: user, access_method: access_method, resource: @resource)

    @service_auth_header = { 'X-SERVICE-TOKEN' => 'random_token' }
    @user_auth_headers = { 'Authorization' => "Bearer #{user.token}" }
  end

  it 'should return unauthorized status when no token is provided in the request' do
    post api_resource_policy_index_path, headers: @user_auth_headers

    expect(response.status).to eq(401)
  end

  it 'should return unauthorized status when no user token is provided' do
    post api_resource_policy_index_path, headers: @service_auth_header

    expect(response.status).to eq(401)
  end

  it 'should return a bad request status if we send a JSON with invalid attributes' do
    post api_resource_policy_index_path,
         params: {
           path: '/some/path',
           user: 'a_user',
           methods: ['a_method']
         },
         headers: valid_auth_headers,
         as: :json

    expect(response.status).to eq(400)
  end

  it 'should return a bad request status as the passed access method does not exist' do
    post api_resource_policy_index_path,
         params: {
           resource_path: '/some/path',
           user: 'user@host.com',
           access_methods: %w(get not_exisitng_method)
         },
         headers: valid_auth_headers,
         as: :json

    expect(response.status).to eq(400)
  end

  it 'should return a 201 status code after a new local resource is created' do
    post api_resource_policy_index_path,
         params: {
           resource_path: '/some/path',
           user: 'user@host.com',
           access_methods: ['get']
         },
         headers: valid_auth_headers,
         as: :json

    expect(response.status).to eq(201)
    expect(Resource.last).to be_local
  end

  it 'should also return a 201 status code for an access method given in capital letters' do
    post api_resource_policy_index_path,
         params: {
           resource_path: '/some/path',
           user: 'user@host.com',
           access_methods: ['GET']
         },
         headers: valid_auth_headers,
         as: :json

    expect(AccessPolicy.first.access_method.name).to eq('get')
  end

  context 'with only one policy attached to resource' do
    it 'should be removed with no content status' do
      delete api_resource_policy_path,
             params: { resource_path: @resource.path },
             headers: valid_auth_headers

      expect(response.status).to eq(204)
    end

    it 'should remove both resource and policy from DB' do
      delete api_resource_policy_path,
             params: { resource_path: @resource.path },
             headers: valid_auth_headers

      expect(resource_and_access_policy_destroyed?).to be_truthy
    end

    def resource_and_access_policy_destroyed?
      Resource.count.zero? && AccessPolicy.count.zero?
    end
  end

  def valid_auth_headers
    @user_auth_headers.merge(@service_auth_header)
  end
end
