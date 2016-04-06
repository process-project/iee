require 'rails_helper'

RSpec.describe PermissionsController, type: :controller do
  render_views
  
  before do
    @user = create(:approved_user)
    @resource = create(:resource)
    @action = create(:action)
    sign_in(@user)
  end
  
  it "should return an error message when neither user_id or group_id is chosen" do
    post :create, permission: {user_id: "", group_id: "", action_id: @action.id,
      resource_id: @resource.id}
    
    expect(response).to render_template(:new)
    expect(response.body).to include(I18n.t("either_user_or_group"))
  end
  
  it "should return an error message when no action was chosen" do
    post :create, permission: {user_id: "", group_id: "", resource_id: @resource.id}
    
    expect(response).to render_template(:new)
    expect(response.body).to include(I18n.t("missing_action"))
  end
  
  it "should add a new permission to the database" do
    post :create, permission: {user_id: @user.id, group_id: "", action_id: @action.id,
      resource_id: @resource.id}
    
    expect(response).to redirect_to(new_permission_path(resource_id: @resource.id))
  end
end