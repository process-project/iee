# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Resource and access policies UI management' do
  include AuthenticationHelper

  scenario 'users should see resources they created' do
    user = create(:approved_user)
    manage = create(:access_method, name: 'manage')
    service = create(:service, users: [user])
    resource = create(:resource, name: 'R name', path: 'my_resource', service: service)
    AccessPolicy.create(access_method: manage, user: user, resource: resource)

    sign_in_as(user)
    visit(resources_path)

    expect(page).to(have_content(resource.name))
    expect(page).to(have_content(resource.uri))
  end

  scenario 'users should not see resources they did not create' do
    # first user creates a resource
    user1 = create(:approved_user)
    manage = create(:access_method, name: 'manage')
    resource = create(:resource)
    create(:access_policy, resource: resource, user: user1, access_method: manage)

    # second user logs in and goes to the resource management page
    user2 = create(:approved_user)
    sign_in_as(user2)
    visit(resources_path)

    expect(page).not_to(have_content(resource.name))
    expect(page).not_to(have_content(resource.uri))
  end
end
