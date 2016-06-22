require 'rails_helper'

RSpec.feature "Resource and access policies UI management" do
  include AuthenticationHelper

  scenario "users should see resources they created" do
    user = create(:approved_user)
    create(:access_method, name: "manage")
    resource_name = "My New Resource"
    service = create(:service, uri: "http://host.com")
    resource_path = "my_resource"

    sign_in_as(user)
    visit(new_resource_path)
    fill_in(:resource_name, with: resource_name)
    fill_in(:resource_path, with: resource_path)
    select(service.uri, from: :resource_service_id)
    find("form#new_resource").find("input.btn").click

    expect(page).to(have_content(resource_name))
    expect(page).to(have_content("#{service.uri}/#{resource_path}"))
  end

  scenario "users should not see resources they did not create" do
    #first user creates a resource
    user1 = create(:approved_user)
    manage = create(:access_method, name: "manage")
    resource = create(:resource)
    create(:access_policy, resource: resource, user: user1, access_method: manage)

    #second user logs in and goes to the resource management page
    user2 = create(:approved_user)
    sign_in_as(user2)
    visit(resources_path)

    expect(page).not_to(have_content(resource.name))
    expect(page).not_to(have_content(resource.uri))
  end

  scenario "access policies for different resources should not mix" do
    #user creates two resources
    user1 = create(:approved_user)
    create(:access_method, name: "manage")
    service = create(:service, uri: "http://host.com")
    resource_name = "My New Resource"
    resource_uri = "my_resource"
    resource_name_2 = "My New Resource 2"
    resource_uri_2 = "my_resource_2"

    #creating the first resource
    sign_in_as(user1)
    visit(new_resource_path)
    fill_in(:resource_name, with: resource_name)
    fill_in(:resource_path, with: resource_uri)
    select(service.uri, from: :resource_service_id)
    find("form#new_resource").find("input.btn").click

    #creating the second resource
    visit(new_resource_path)
    fill_in(:resource_name, with: resource_name_2)
    fill_in(:resource_path, with: resource_uri_2)
    select(service.uri, from: :resource_service_id)
    find("form#new_resource").find("input.btn").click

    #showing the access policy management tab for the first resource
    resource_1 = Resource.find_by(path: resource_uri)
    visit(new_access_policy_path(resource_id: resource_1.id))

    #the page should contain two manage texts: one for the resource and the second one for the menu
    expect(page).to(have_content("manage", count: 2))
  end
end
