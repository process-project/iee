# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Resource managers' do
  let(:user) { create(:approved_user) }
  let(:service) { create(:service, users: [user]) }
  let(:global_resource) do
    create(:resource, service: service, resource_type: :global)
  end
  let(:local_resource) do
    create(:resource, service: service, resource_type: :local)
  end

  before { login_as(user) }

  it 'returns an error message when neither user_id or group_id is chosen' do
    post resource_resource_managers_path(global_resource),
         params: resource_manager_params('')

    expect(response.body).to include(I18n.t('either_user_or_group'))
  end

  it 'should add a new global resource manager' do
    post resource_resource_managers_path(global_resource),
         params: resource_manager_params(user.id)
    resource_manager = ResourceManager.last

    expect(response).
      to redirect_to(service_global_policy_path(service, global_resource))
    expect(resource_manager.user).to eq(user)
    expect(resource_manager.resource).to eq(global_resource)
  end

  it 'should add a new local resource manager' do
    post resource_resource_managers_path(local_resource),
         params: resource_manager_params(user.id)
    resource_manager = ResourceManager.last

    expect(response).
      to redirect_to(service_local_policy_path(service, local_resource))
    expect(resource_manager.user).to eq(user)
    expect(resource_manager.resource).to eq(local_resource)
  end

  it 'should create only single manager for a given resource and user' do
    expect do
      post resource_resource_managers_path(global_resource),
           params: resource_manager_params(user.id)

      post resource_resource_managers_path(global_resource),
           params: resource_manager_params(user.id)
    end.to change { ResourceManager.count }.by(1)
  end

  def resource_manager_params(user_id)
    {
      resource_manager: {
        user_id: user_id,
        group_id: ''
      }
    }
  end
end
