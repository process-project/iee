# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Service global policies' do
  let(:user) { create(:approved_user) }

  before { login_as(user) }

  describe 'GET /services/:id/global_policies' do
    it 'lists service global policies' do
      service = create(:service, users: [user])
      create(:global_resource, name: 'resource_1')
      create(:global_resource, service: service, name: 'resource_2')
      create(:global_resource, service: service, name: 'resource_3')
      create(:local_resource, service: service, name: 'resource_4')

      get service_global_policies_path(service)

      expect(response.body).to_not include('resource_1')
      expect(response.body).to include('resource_2')
      expect(response.body).to include('resource_3')
      expect(response.body).to_not include('resource_4')
    end

    it 'denies viewing not owned service global policies' do
      service = create(:service)

      get service_global_policies_path(service)

      expect(response.status).to eq(302)
    end
  end

  describe 'POST /services/:id/global_policies' do
    it 'creates global policy for owned service' do
      service = create(:service, users: [user])

      post service_global_policies_path(service),
           params: { resource: { name: 'my_resource', pretty_path: '/my_path' } }
      new_resource = Resource.last

      expect(new_resource.name).to eq('my_resource')
      expect(new_resource.path).to eq('/my_path')
      expect(new_resource).to be_global
    end

    it 'current user as manager for new created resource' do
      service = create(:service, users: [user])

      post service_global_policies_path(service),
           params: { resource: { name: 'my_resource', pretty_path: '/my_path' } }
      new_resource = Resource.last

      expect(new_resource.resource_managers.where(user: user)).to be_exist
    end

    it 'denies creating global policy for not owned service' do
      service = create(:service)

      post service_global_policies_path(service),
           params: { resource: { name: 'my_resource', pretty_path: '/my_path' } }

      expect(response.status).to eq(302)
    end
  end

  describe 'PUT /services/:id/global_policies/:id' do
    it 'updates global policy for owned service' do
      service = create(:service, users: [user])
      resource = create(:global_resource, service: service)

      put service_global_policy_path(service, resource),
          params: { resource: { name: 'my_resource', pretty_path: '/my_path' } }

      resource.reload

      expect(resource.name).to eq('my_resource')
      expect(resource.path).to eq('/my_path')
    end

    it 'denies updates global policy for not owned service' do
      service = create(:service)
      resource = create(:global_resource, service: service)

      put service_global_policy_path(service, resource),
          params: { resource: { name: 'my_resource', pretty_path: '/my_path' } }

      expect(response.status).to eq(302)
    end
  end

  describe 'DELETE /services/:id/global_policies/:id' do
    it 'deletes global policy for owned service' do
      service = create(:service, users: [user])
      resource = create(:global_resource, service: service)

      expect { delete service_global_policy_path(service, resource) }.
        to change { Resource.count }.by(-1)
    end

    it 'deletes global policy for owned service' do
      service = create(:service)
      resource = create(:global_resource, service: service)

      expect { delete service_global_policy_path(service, resource) }.
        to change { Resource.count }.by(0)
      expect(response.status).to eq(302)
    end
  end
end
