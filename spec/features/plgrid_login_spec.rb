require 'rails_helper'

RSpec.feature 'PLGrid authentication' do
  include OauthHelper
  include AuthenticationHelper

  scenario 'login' do
    user = build(:plgrid_user)

    plgrid_sign_in_as(user)

    expect(page).to have_content(user.email)
  end

  scenario 'connect with existing account' do
    user = create(:user)

    sign_in_as(user)
    plgrid_sign_in_as(build(:user, plgrid_login: 'plguser', email: user.email))
    user.reload

    expect(user.plgrid_login).to eq('plguser')
  end
end

