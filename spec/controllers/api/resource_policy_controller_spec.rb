require 'rails_helper'

RSpec.describe Api::ResourcePolicyController do
  context "Resource policy API" do
    before do
      service = create(:service, uri: "https://service.host.com", token: "random_token")
      access_method = create(:access_method, name: "get")
      user = create(:user, email: "user@host.com")
      @resource = create(:resource, service: service)
      create(:access_policy, user: user, access_method: access_method,
                resource: @resource)
    end

    it "should return an unauthorized status when no token is provided in the request" do
      post :create

      expect(response.status).to eq(401)
    end

    it "should return a bad request status if we send a JSON with invalid attributes" do
      set_headers

      post :create,
           params: { path: "/some/path", user: "a_user", methods: [ "a_method" ] }

      expect(response.status).to eq(400)
    end

    it "should return a bad request status as the passed access method does not exist" do
      set_headers

      post :create,
           params: { resource_path: "/some/path", user: "user@host.com", access_methods: [ "get", "not_exisitng_method" ] }

      expect(response.status).to eq(400)
    end

    it "should return a 201 status code" do
      set_headers

      post :create,
           params: { resource_path: "/some/path", user: "user@host.com", access_methods: [ "get" ] }

      expect(response.status).to eq(201)
    end

    it "should also return a 201 status code for an access method given in capital letters" do
      set_headers

      post :create,
           params: { resource_path: "/some/path", user: "user@host.com", access_methods: [ "GET" ] }

      expect(AccessPolicy.first.access_method.name).to eq("get")
    end

    context "with only one policy attached to resource" do
      before do
        request.headers["X-SERVICE-TOKEN"] = "random_token"
      end

      it "should be removed with no content status" do
        delete :destroy,
               params: { resource_path: @resource.path }

        expect(response.status).to eq(204)
      end

      it "should remove both resource and policy from DB" do
        delete :destroy,
               params: { resource_path: @resource.path }

        expect(resource_and_access_policy_destroyed?).to be_truthy
      end
    end
  end

  def set_headers
    request.headers["X-SERVICE-TOKEN"] = "random_token"
    request.headers["Content-Type"] = "application/json"
  end

  def resource_and_access_policy_destroyed?
    Resource.count == 0 && AccessPolicy.count == 0
  end
end
