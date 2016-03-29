require 'rails_helper'

RSpec.feature "Suprvisor confirmations" do
  include AuthenticationHelper
  
  scenario "non supervisor users should not see the confirmation page" do
    user = create(:approved_user)
    
    sign_in_as(user)
    
    expect(page).not_to have_content(I18n.t("user_confirmation"))
  end
  
  scenario "supervisor users should see the confirmation page" do
    user = create(:supervisor_user)
    
    sign_in_as(user)
    
    expect(page).to have_content(I18n.t("user_confirmation"))
  end
end