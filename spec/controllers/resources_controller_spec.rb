require 'rails_helper'

RSpec.describe ResourcesController, type: :controller do
  render_views
  
  it "should create a new resource" do
    user = create(:approved_user)
    create(:action, name: "manage")
    sign_in(user)
    
    post :create, resource: FactoryGirl.attributes_for(:resource)
    
    expect(response).to redirect_to(resources_path)
  end
end