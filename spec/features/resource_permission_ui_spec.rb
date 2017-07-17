# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Resource and access policies UI management' do
  include AuthenticationHelper

  scenario 'shows access policies for owned services' do
    user = create(:approved_user)
    service = create(:service, users: [user])
    resource = create(:resource, service: service, resource_type: :global)
    get_ac = create(:access_method, name: 'get')
    AccessPolicy.create(access_method: get_ac, user: user, resource: resource)

    sign_in_as(user)
    visit(service_global_policy_path(service, resource))

    expect(page).to have_content(resource.name)
    expect(page).to have_content(resource.uri)
    expect(page).to have_content('get')
  end

  scenario 'denies to see not owned service access policies' do
    # first user creates a resource
    user = create(:approved_user)
    resource = create(:resource)

    sign_in_as(user)
    visit(service_global_policy_path(resource.service, resource))

    expect(page).not_to(have_content(resource.name))
    expect(page).not_to(have_content(resource.uri))
  end
end
