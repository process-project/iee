require 'rails_helper'

RSpec.feature "Resource and permissions UI management" do
  include AuthenticationHelper
  
  scenario "users should see resources they created" do
    user = create(:approved_user)
    create(:action, name: "manage")
    resource_name = "My New Resource"
    resource_uri = "http://host.com/my_resource"
    
    sign_in_as(user)
    visit(new_resource_path)
    fill_in(:resource_name, with: resource_name)
    fill_in(:resource_uri, with: resource_uri)
    find("form#new_resource").find("input.btn").click
    
    expect(page).to(have_content(resource_name))
    expect(page).to(have_content(resource_uri))
  end
  
  scenario "users should not see resources they did not created" do
    #first user creates a resource
    user1 = create(:approved_user)
    create(:action, name: "manage")
    resource_name = "My New Resource"
    resource_uri = "http://host.com/my_resource"
    
    sign_in_as(user1)
    visit(new_resource_path)
    fill_in(:resource_name, with: resource_name)
    fill_in(:resource_uri, with: resource_uri)
    find("form#new_resource").find("input.btn").click
    #we cannot use JavaScript so this is used instead
    page.driver.submit(:delete, destroy_user_session_path, {})
    
    #second user logs in and goes to the resource management page
    user2 = create(:approved_user)
    sign_in_as(user2)
    visit(resources_path)
    
    expect(page).not_to(have_content(resource_name))
    expect(page).not_to(have_content(resource_uri))
  end
  
  scenario "permissions for different resources should not mix" do
    #user creates two resources
    user1 = create(:approved_user)
    create(:action, name: "manage")
    resource_name = "My New Resource"
    resource_uri = "http://host.com/my_resource"
    resource_name_2 = "My New Resource 2"
    resource_uri_2 = "http://host.com/my_resource_2"
    
    #creating the first resource
    sign_in_as(user1)
    visit(new_resource_path)
    fill_in(:resource_name, with: resource_name)
    fill_in(:resource_uri, with: resource_uri)
    find("form#new_resource").find("input.btn").click
    
    #creating the second resource
    visit(new_resource_path)
    fill_in(:resource_name, with: resource_name_2)
    fill_in(:resource_uri, with: resource_uri_2)
    find("form#new_resource").find("input.btn").click
    
    #showing the permission management tab for the first resource
    resource_1 = Resource.find_by(uri: resource_uri)
    visit(new_permission_path(resource_id: resource_1.id))
    
    #the page should contain two manage texts: one for the resource and the second one for the menu
    expect(page).to(have_content("manage", count: 2))
  end
end