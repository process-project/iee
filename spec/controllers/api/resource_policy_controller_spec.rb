require 'rails_helper'

RSpec.describe Api::ResourcePolicyController do
  context "Resource policy API" do
    before do
      create(:service, uri: "https://service.host.com", token: "random_token")
      create(:access_method, name: "get")
      create(:user, email: "user@host.com")
    end
    
    it "should return an unauthorized status when no token is provided in the request" do
      post :create
      
      expect(response.status).to eq(401)
    end
    
    it "should return a bad request status if we send a bad json body" do
      request.headers["X-SERVICE-TOKEN"] = "random_token"
      request.headers["Content-Type"] = "application/json"
      
      post :create, '{ "path": "/some/path", "user": "a_user", "methods": [ "a_method" ]}'
      
      expect(response.status).to eq(400)
    end
    
    it "should return a bad request status as the passed access method does not exist" do
      request.headers["X-SERVICE-TOKEN"] = "random_token"
      request.headers["Content-Type"] = "application/json"
      
      post :create, '{ "resource_path": "/some/path", "user": "user@host.com", "methods": [ "get", "post" ]}'
      
      expect(response.status).to eq(400)
    end
    
    it "should return a 201 status code" do
      request.headers["X-SERVICE-TOKEN"] = "random_token"
      request.headers["Content-Type"] = "application/json"
      
      post :create, '{ "resource_path": "/some/path", "user": "user@host.com", "access_methods": [ "get" ]}'
      
      expect(response.status).to eq(201)
    end
  end
end