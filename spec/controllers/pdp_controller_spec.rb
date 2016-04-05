require 'rails_helper'

RSpec.describe PdpController do
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
  end

  context 'as anonymous' do
    it 'returns 403' do
      get :index, uri: 'some_resource', permission: 'get'

      expect(response.status).to eq(403)
    end
  end
end
