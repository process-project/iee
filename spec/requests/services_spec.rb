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

        expect(response.status).to eq(302)
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

      it 'saves new access methods' do
        expect do
          post '/services/', params: {
            service: {
              name: 's',
              uri: 'http://a.b',
              access_method_ids: ['ac_name']
            }
          }
        end.to change { AccessMethod.count }.by(1).
          and change { Service.count }.by(1)
        expect(AccessMethod.find_by(name: 'ac_name').service.name).to eq 's'
      end

      it 'does not change existing access methods' do
        global_am = create(:access_method)
        other_service_am = create(:access_method, :service_scoped)
        expect do
          post '/services/', params: {
            service: {
              name: 's',
              uri: 'http://a.b',
              access_method_ids: [global_am.id, other_service_am.id]
            }
          }
        end.to change { AccessMethod.count }.by(0).
          and change { Service.count }.by(1)
        expect(global_am.service).to be_nil
        expect(other_service_am.service.name).not_to eq 's'
      end

      it 'allows same-name access methods for different services' do
        other_service_am = create(:access_method, :service_scoped)
        expect do
          post '/services/', params: {
            service: {
              uri: 'http://a.b',
              access_method_ids: [other_service_am.name]
            }
          }
        end.to change { AccessMethod.count }.by(1).
          and change { Service.count }.by(1)
        expect(AccessMethod.where(name: other_service_am.name).count).to eq 2
        expect(AccessMethod.where(name: other_service_am.name).map(&:service)).
          to match_array Service.all
      end

      it 'ignores reusing global access method name' do
        global_am = create(:access_method)
        expect do
          post '/services/', params: {
            service: {
              name: 's',
              uri: 'http://a.b',
              access_method_ids: [global_am.name]
            }
          }
        end.to change { AccessMethod.count }.by(0).
          and change { Service.count }.by(1)
        expect(global_am.service).to be_nil
      end
    end

    describe 'PUT /services/:id' do
      let(:service) { create(:service, users: [user]) }

      it 'denies to update not owned service' do
        service = create(:service)

        put service_path(service), params: { service: { name: 'new_name' } }

        expect(response.status).to eq(302)
      end

      it 'updates attributes for managed service' do
        put service_path(service),
            params: { service: { name: 'new_name', uri: 'http://new.pl' } }
        service.reload

        expect(service.name).to eq('new_name')
        expect(service.uri).to eq('http://new.pl')
      end

      it 'updates ownership' do
        put service_path(service),
            params: { service: { user_ids: [user.id, create(:user).id] } }
        service.reload

        expect(service.users.count).to eq 2
      end

      it 'prevents orphan services' do
        put service_path(service),
            params: { service: { name: 'orphan?', user_ids: [] } }
        service.reload

        expect(service.users.count).to eq 1
      end

      it 'retains existing service-scoped access methods' do
        access_method = create(:access_method, service: service)

        expect do
          put service_path(service),
              params: { service: { access_method_ids: [access_method.id] } }
        end.to change { AccessMethod.count }.by(0)
      end

      it 'deletes no longer related access methods' do
        create(:access_method, service: service)

        expect do
          put service_path(service),
              params: { service: { name: service.name, access_method_ids: [] } }
        end.to change { AccessMethod.count }.by(-1)
      end

      it 'does not change existing access methods' do
        global_am = create(:access_method)
        other_service_am = create(:access_method, :service_scoped)
        expect do
          put service_path(service), params: {
            service: {
              access_method_ids: [global_am.id, other_service_am.id]
            }
          }
        end.to change { AccessMethod.count }.by(0)
        expect(global_am.service).to be_nil
        expect(other_service_am.service.name).not_to eq 's'
      end

      it 'allows same-name access methods for different services' do
        other_service_am = create(:access_method, :service_scoped)
        expect do
          put service_path(service), params: {
            service: {
              access_method_ids: [other_service_am.name]
            }
          }
        end.to change { AccessMethod.count }.by(1)
        expect(AccessMethod.where(name: other_service_am.name).count).to eq 2
        expect(AccessMethod.where(name: other_service_am.name).map(&:service)).
          to match_array Service.all
      end

      it 'ignores reusing global access method name' do
        global_am = create(:access_method)
        expect do
          put service_path(service), params: {
            service: {
              access_method_ids: [global_am.name]
            }
          }
        end.to change { AccessMethod.count }.by(0)
        expect(global_am.service).to be_nil
      end

      it 'ignores access method name duplication' do
        access_method = create(:access_method, service: service)
        expect do
          put service_path(service), params: {
            service: {
              access_method_ids: [access_method.id, access_method.name, 'q', 'q']
            }
          }
        end.to change { AccessMethod.count }.by(1)
        expect(service.access_methods.pluck(:name)).
          to match_array [access_method.name, 'q']
      end
    end

    describe 'DELETE /service/:id' do
      it 'denies to destroy not owned service' do
        service = create(:service)

        delete service_path(service)

        expect(response.status).to eq(302)
      end

      it 'destroys managed service' do
        service = create(:service, users: [user])

        expect { delete service_path(service) }.to change { Service.count }.by(-1)
      end
    end
  end
end
