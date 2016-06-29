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
    
    it "should return a bad request status if we send a json with invalid attributes" do
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
    
    it "should also return a 201 status code for an access method given in capital letters" do
      set_headers
      
      post :create, '{ "resource_path": "/some/path", "user": "user@host.com", "access_methods": [ "GET" ]}'
        
      expect(AccessPolicy.first.access_method.name).to eq("get")
    end
  end
  
  def set_headers
    request.headers["X-SERVICE-TOKEN"] = "random_token"
    request.headers["Content-Type"] = "application/json"
  end
end