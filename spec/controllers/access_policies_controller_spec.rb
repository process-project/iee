require 'rails_helper'

RSpec.describe AccessPoliciesController, type: :controller do
  render_views

  before do
    @user = create(:approved_user)
    @resource = create(:resource)
    @access_method = create(:access_method)
    sign_in(@user)
  end

  it "should return an error message when neither user_id or group_id is chosen" do
    post :create, params: access_policy_params("")

    expect(response).to render_template(:new)
    expect(response.body).to include(I18n.t("either_user_or_group"))
  end

  it "should return an error message when no access method was chosen" do
    post :create,
         params: {
           access_policy: {
             user_id: "",
             group_id: "",
             resource_id: @resource.id
           }
         }

    expect(response).to render_template(:new)
    expect(response.body).to include(I18n.t("missing_access_method"))
  end

  it "should add a new access policy to the database" do
    post :create, params: access_policy_params(@user.id)

    expect(response).to redirect_to(new_access_policy_path(resource_id: @resource.id))
  end

  it "should create only single access policy for a given method" do
    post :create, params: access_policy_params(@user.id)
    post :create, params: access_policy_params(@user.id)
    post :create, params: access_policy_params(@user.id)

    get :new, params: { resource_id: @resource.id }

    expect(response.body).to have_selector("span.label:contains('#{@access_method.name}')", count: 1)
  end

  def access_policy_params(user_id)
    {
      access_policy: {
        user_id: user_id,
        group_id: "",
        access_method_id: @access_method.id,
        resource_id: @resource.id
      }
    }
  end
end
