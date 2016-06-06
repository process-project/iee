require 'rails_helper'

RSpec.describe Api::PdpController do
  context 'as logged in user' do
    let(:user) { create(:user) }
    let(:resource) { create(:resource) }
    let(:action) { create(:action, name: 'get') }

    before { sign_in(user) }

    it 'returns 200 when user requested permission' do
      create(:user_permission, user: user, resource: resource, action: action)

      get :index, uri: resource.uri, permission: 'get'

      expect(response.status).to eq(200)
    end

    it 'return 403 when user does not have requested permission' do
      get :index, uri: resource.uri, permission: 'get'

      expect(response.status).to eq(403)
    end

    it 'returns 403 for non existing resource' do
      get :index, uri: 'non_existing', permission: 'get'

      expect(response.status).to eq(403)
    end
    
    context "resource with regular expressions" do
      let(:resource) { create(:resource, uri: "http://localhost/.*") }
      
      before do
        sign_in(user)
        create(:user_permission, user: user, resource: resource, action: action)
      end
      
      it "returns 200 for matching resource" do
        get :index, uri: "http://localhost/something", permission: "get"
        
        expect(response.status).to eq(200)
      end
      
      it "returns 403 for not matching resources" do
        get :index, uri: "http://localhost2/something", permission: "get"
        
        expect(response.status).to eq(403)
      end
    end
  end

  context 'as anonymous' do
    it 'returns 401' do
      get :index, uri: 'some_resource', permission: 'get'

      expect(response.status).to eq(401)
      expect(response.headers['WWW-Authenticate'])
        .to eq('Bearer realm="example"')
    end
  end
end
