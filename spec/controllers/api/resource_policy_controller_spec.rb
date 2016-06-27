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
      
      post :create, '{ "path": "/some/path", "user": "a_user", "methods": [ "a_method" ]}'
      
      expect(response.status).to eq(400)
    end
    
    it "should return a bad request status as the passed access method does not exist" do
      set_headers
      
      post :create, '{ "resource_path": "/some/path", "user": "user@host.com", "access_methods": [ "get", "not_exisitng_method" ]}'
      
      expect(response.status).to eq(400)
    end
    
    it "should return a 201 status code" do
      set_headers
      
      post :create, '{ "resource_path": "/some/path", "user": "user@host.com", "access_methods": [ "get" ]}'
      
      expect(response.status).to eq(201)
    end
    
    it "should remove a resource when only one policy is attached to it" do
      request.headers["X-SERVICE-TOKEN"] = "random_token"
      
      delete :delete, resource_path: @resource.path
      
      expect(Resource.all.count).to eq(0)
      expect(AccessPolicy.all.count).to eq(0)
      expect(response.status).to eq(204)
    end
  end
  
  def set_headers
    request.headers["X-SERVICE-TOKEN"] = "random_token"
    request.headers["Content-Type"] = "application/json"
  end
end