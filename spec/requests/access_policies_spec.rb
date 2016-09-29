# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Access Policies' do
  before do
    @user = create(:approved_user)
    @service = create(:service, users: [@user])
    @resource = create(:resource, service: @service, resource_type: :global)
    @access_method = create(:access_method)
    login_as(@user)
  end

  it 'returns an error message when neither user_id or group_id is chosen' do
    post resource_access_policies_path(@resource),
         params: access_policy_params('')

    expect(response.body).to include(I18n.t('either_user_or_group'))
  end

  it 'should return an error message when no access method was chosen' do
    post resource_access_policies_path(@resource),
         params: {
           access_policy: {
             user_id: '',
             group_id: ''
           }
         }

    expect(response.body).to include(I18n.t('missing_access_method'))
  end

  it 'should add a new access policy to the database' do
    post resource_access_policies_path(@resource),
         params: access_policy_params(@user.id)

    expect(response).
      to redirect_to(service_global_policy_path(@service, @resource))
  end

  it 'should create only single access policy for a given method' do
    expect do
      post resource_access_policies_path(@resource),
           params: access_policy_params(@user.id)

      post resource_access_policies_path(@resource),
           params: access_policy_params(@user.id)

      post resource_access_policies_path(@resource),
           params: access_policy_params(@user.id)
    end.to change { AccessPolicy.count }.by(1)
  end

  def access_policy_params(user_id)
    {
      access_policy: {
        user_id: user_id,
        group_id: '',
        access_method_id: @access_method.id,
        resource_id: @resource.id
      }
    }
  end
end
