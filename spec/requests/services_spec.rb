# frozen_string_literal: true
require 'rails_helper'

describe 'Services controller' do
  context 'with no user signed in' do
    describe 'GET /services' do
      it 'is redirects to signin url' do
        get '/services'
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  context 'with user signed in' do
    let(:user) { create(:user, :approved) }
    let(:service) { create(:service) }
    before(:each) do
      login_as(user)
    end

    describe 'GET /services' do
      it 'shows only owned services to the user' do
        user.services << service
        other_service = create(:service)

        get '/services/'

        expect(response.body).to include service.uri
        expect(response.body).not_to include other_service.uri
      end

      it 'notifies about absence of owned services' do
        get '/services/'

        expect(response.body).to include I18n.t('services.index.nothing')
      end

      it 'allows to navigate to new service form' do
        get '/services/'

        expect(response.body).to include I18n.t('services.index.add')
        expect(response.body).to include new_service_path
      end
    end

    describe 'DELETE /services/:id' do
      it 'prevents removal of not owned service' do
        delete "/services/#{service.id}"

        expect(response.status).to eq(403)
      end

      it 'removes service with all related resources' do
        user.services << service
        create(:resource, service: service)

        expect do
          delete "/services/#{service.id}"
        end.to change { Resource.count }.by(-1).
          and change { Service.count }.by(-1)

        expect(response).to redirect_to(services_path)
      end
    end

    describe 'POST /services' do
      it 'sets service ownership to the current user' do
        expect do
          post '/services/', params: { service: { uri: 'http://a.b' } }
        end.to change { ServiceOwnership.count }.by(1)
        expect(ServiceOwnership.first.service.uri).to eq 'http://a.b'
        expect(ServiceOwnership.first.user).to eq user
      end
    end
  end
end
