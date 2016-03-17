module AuthenticationHelper
  include Devise::TestHelpers

  def plgrid_sign_in_as(user)
    stub_oauth(
      :open_id,
      nickname: user.plgrid_login,
      email: user.email
    )
    visit user_omniauth_authorize_path(:open_id)
  end

  def sign_in_as(user)
    visit new_user_session_path

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"
  end
end

