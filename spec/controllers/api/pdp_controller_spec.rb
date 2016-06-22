require 'rails_helper'

RSpec.describe Api::PdpController do
  context 'as logged in user' do
    let(:user) { create(:user) }
    let(:service) { create(:service, uri:'http://localhost') }
    let(:resource) { create(:resource, service: service) }
    let(:access_method) { create(:access_method, name: 'get') }

    before { sign_in(user) }

    it 'returns 200 when user has permission' do
      create(:user_access_policy, user: user, resource: resource, access_method: access_method)

      get :index, uri: resource.uri, access_method: 'get'

      expect(response.status).to eq(200)
    end

    it 'returns 403 when user does not have permission' do
      get :index, uri: resource.uri, access_method: 'get'

      expect(response.status).to eq(403)
    end

    it 'returns 403 for non existing resource' do
      get :index, uri: 'non_existing', access_method: 'get'

      expect(response.status).to eq(403)
    end

    context 'resource with regular expressions' do
      let(:resource) { create(:resource, path: 'path/.*', service: service) }

      before do
        create(:user_access_policy, user: user, resource: resource, access_method: access_method)
      end

      it 'returns 200 for matching resource' do
        get :index, uri: 'http://localhost/path/something', access_method: 'get'

        expect(response.status).to eq(200)
      end

      it 'returns 403 for not matching resources' do
        get :index, uri: 'http://localhost/path2/something', access_method: 'get'

        expect(response.status).to eq(403)
      end
      
      context "several resources with overlapping regular expressions" do
        let(:resource_2) { create(:resource, path: "path/extra/.*", service: service) }
        let(:access_method_2) { create(:access_method, name: "post") }
        
        before do
          create(:user_access_policy, user: user, resource: resource_2,
            access_method: access_method_2)
        end
        
        it "returns 403 as conflicting access policies exist" do
          get :index, uri: 'http://localhost/path/extra/something', access_method: 'get'

          expect(response.status).to eq(403)
        end
      end
    end
  end

  context 'as anonymous' do
    it 'returns 401' do
      get :index, uri: 'some_resource', method: 'get'

      expect(response.status).to eq(401)
      expect(response.headers['WWW-Authenticate'])
        .to eq('Bearer realm="example"')
    end
  end
end
