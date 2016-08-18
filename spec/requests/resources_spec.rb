# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Resources' do
  context 'with user signed in' do
    let(:user) { create(:user, :approved) }
    let(:service) { create(:service) }
    before(:each) do
      create(:access_method, name: 'manage')
      login_as(user)
    end

    describe 'GET /resources/new' do
      it 'shows only owned services to the user' do
        user.services << service
        other_service = create(:service)

        get '/resources/new'

        expect(response.body).to include service.uri
        expect(response.body).not_to include other_service.uri
      end
    end

    describe 'POST /resources' do
      it 'creates a new global resource for owned service' do
        user.services << service

        expect do
          post '/resources/',
               params: {
                 resource: FactoryGirl.attributes_for(:resource).merge(service_id: service.id)
               }
        end.to change { Resource.count }.by(1)
        expect(Resource.last).to be_global
        expect(response).to redirect_to(resources_path)
      end

      it 'prevents creating a resource for not owned service' do
        post '/resources/',
             params: {
               resource: FactoryGirl.attributes_for(:resource).merge(service_id: service.id)
             }

        expect(response.status).to eq(403)
      end
    end

    describe 'DELETE /resources/:id' do
      it 'removes resource even for not owned service' do
        resource = create(:resource)
        create(:access_policy, user: user, resource: resource)

        expect(user.services).to be_empty
        expect do
          delete "/resources/#{resource.id}"
        end.to change { Resource.count }.by(-1)
      end
    end
  end
end
