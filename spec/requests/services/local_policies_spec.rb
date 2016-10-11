# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Service local policies' do
  let(:user) { create(:approved_user) }

  before { login_as(user) }

  describe 'GET /services/:id/local_policies' do
    it 'lists service local policies' do
      service = create(:service, users: [user])
      create(:local_resource, name: 'r1')
      create(:local_resource, service: service, name: 'r2')
      create(:local_resource, service: service, name: 'r3')
      create(:global_resource, service: service, name: 'r4')

      get service_local_policies_path(service)

      expect(response.body).to_not include('r1')
      expect(response.body).to include('r2')
      expect(response.body).to include('r3')
      expect(response.body).to_not include('r4')
    end

    it 'denies viewing not owned service local policies' do
      service = create(:service)

      get service_local_policies_path(service)

      expect(response.status).to eq(302)
    end
  end

  describe 'POST /services/:id/local_policies' do
    it 'creates local policy for owned service' do
      service = create(:service, users: [user])

      post service_local_policies_path(service),
           params: { resource: { name: 'my_resource', path: '/my_path' } }
      new_resource = Resource.last

      expect(new_resource.name).to eq('my_resource')
      expect(new_resource.path).to eq('/my_path')
      expect(new_resource).to be_local
    end

    it 'denies creating local policy for not owned service' do
      service = create(:service)

      post service_local_policies_path(service),
           params: { resource: { name: 'my_resource', path: '/my_path' } }

      expect(response.status).to eq(302)
    end
  end

  describe 'PUT /services/:id/local_policies/:id' do
    it 'updates local policy for owned service' do
      service = create(:service, users: [user])
      resource = create(:local_resource, service: service)

      put service_local_policy_path(service, resource),
          params: { resource: { name: 'my_resource', path: '/my_path' } }

      resource.reload

      expect(resource.name).to eq('my_resource')
      expect(resource.path).to eq('/my_path')
    end

    it 'denies updates local policy for not owned service' do
      service = create(:service)
      resource = create(:local_resource, service: service)

      put service_local_policy_path(service, resource),
          params: { resource: { name: 'my_resource', path: '/my_path' } }

      expect(response.status).to eq(302)
    end
  end

  describe 'DELETE /services/:id/local_policies/:id' do
    it 'deletes local policy for owned service' do
      service = create(:service, users: [user])
      resource = create(:local_resource, service: service)

      expect { delete service_local_policy_path(service, resource) }.
        to change { Resource.count }.by(-1)
    end

    it 'deletes local policy for owned service' do
      service = create(:service)
      resource = create(:local_resource, service: service)

      expect { delete service_local_policy_path(service, resource) }.
        to change { Resource.count }.by(0)
      expect(response.status).to eq(302)
    end
  end
end
