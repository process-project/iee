# frozen_string_literal: true

module AuthenticationHelper
  def plgrid_sign_in_as(user)
    stub_oauth(
      :open_id,
      name: "#{user.first_name} #{user.last_name}",
      nickname: user.plgrid_login,
      email: user.email
    )
    visit user_open_id_omniauth_authorize_path
  end

  def sign_in_as(user)
    visit new_user_session_path

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
  end
end
