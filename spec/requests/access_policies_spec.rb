# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Access Policies' do
  let(:user) { create(:approved_user) }
  let(:service) { create(:service, users: [user]) }
  let(:access_method) { create(:access_method) }
  let(:global_resource) do
    create(:resource, service: service, resource_type: :global)
  end
  let(:local_resource) do
    create(:resource, service: service, resource_type: :local)
  end

  before { login_as(user) }

  it 'returns an error message when neither user_id or group_id is chosen' do
    post resource_access_policies_path(global_resource),
         params: access_policy_params('')

    expect(response.body).to include(I18n.t('either_user_or_group'))
  end

  it 'should return an error message when no access method was chosen' do
    error_msg = I18n.t('activerecord.errors.models.access_policy.attributes.access_method.required')
    post resource_access_policies_path(global_resource),
         params: {
           access_policy: {
             user_id: '',
             group_id: ''
           }
         }

    expect(response.body).to include(error_msg)
  end

  it 'should add a new global access policy to the database' do
    post resource_access_policies_path(global_resource),
         params: access_policy_params(user.id)

    expect(response).
      to redirect_to(service_global_policy_path(service, global_resource))
  end

  it 'should add a new local access policy to the database' do
    post resource_access_policies_path(local_resource),
         params: access_policy_params(user.id)

    expect(response).
      to redirect_to(service_local_policy_path(service, local_resource))
  end

  it 'should create only single access policy for a given method' do
    expect do
      post resource_access_policies_path(global_resource),
           params: access_policy_params(user.id)

      post resource_access_policies_path(global_resource),
           params: access_policy_params(user.id)

      post resource_access_policies_path(global_resource),
           params: access_policy_params(user.id)
    end.to change { AccessPolicy.count }.by(1)
  end

  def access_policy_params(user_id)
    {
      access_policy: {
        user_id: user_id,
        group_id: '',
        access_method_id: access_method.id
      }
    }
  end
end
