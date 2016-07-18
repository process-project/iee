require 'rails_helper'


RSpec.describe 'Resource policies API' do
  before do
    service = create(:service,
                     uri: "https://service.host.com", token: "random_token")
    access_method = create(:access_method, name: "get")
    user = create(:user, email: "user@host.com")
    @resource = create(:resource, service: service)
    create(:access_policy,
           user: user, access_method: access_method, resource: @resource)
  end

  it "should return unauthorized status when no token is provided in the request" do
    post api_resource_policy_index_path

    expect(response.status).to eq(401)
  end

  it "should return a bad request status if we send a JSON with invalid attributes" do
    post api_resource_policy_index_path,
          params: {
             path: "/some/path",
             user: "a_user",
             methods: [ "a_method" ]
          },
          headers: {
            "X-SERVICE-TOKEN" => "random_token",
          },
          as: :json

    expect(response.status).to eq(400)
  end

  it "should return a bad request status as the passed access method does not exist" do
    post api_resource_policy_index_path,
          params: {
            resource_path: "/some/path",
            user: "user@host.com",
            access_methods: [ "get", "not_exisitng_method" ]
          },
          headers: {
            "X-SERVICE-TOKEN" => "random_token",
          },
          as: :json

    expect(response.status).to eq(400)
  end

  it "should return a 201 status code" do
    post api_resource_policy_index_path,
          params: {
            resource_path: "/some/path",
            user: "user@host.com",
            access_methods: [ "get" ]
          },
          headers: {
            "X-SERVICE-TOKEN" => "random_token",
          },
          as: :json

    expect(response.status).to eq(201)
  end

  it "should also return a 201 status code for an access method given in capital letters" do
    post api_resource_policy_index_path,
          params: {
            resource_path: "/some/path",
            user: "user@host.com",
            access_methods: [ "GET" ] },
          headers: {
            "X-SERVICE-TOKEN" => "random_token",
          },
          as: :json

    expect(AccessPolicy.first.access_method.name).to eq("get")
  end

  context "with only one policy attached to resource" do
    it "should be removed with no content status" do
      delete api_resource_policy_path,
             params: { resource_path: @resource.path },
             headers: {
               "X-SERVICE-TOKEN" => "random_token",
             }

      expect(response.status).to eq(204)
    end

    it "should remove both resource and policy from DB" do
      delete api_resource_policy_path,
             params: { resource_path: @resource.path },
             headers: {
               "X-SERVICE-TOKEN" => "random_token",
             }

      expect(resource_and_access_policy_destroyed?).to be_truthy
    end

    def resource_and_access_policy_destroyed?
      Resource.count == 0 && AccessPolicy.count == 0
    end
  end
end
