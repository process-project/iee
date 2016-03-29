require 'rails_helper'

RSpec.feature 'PLGrid authentication' do
  include OauthHelper
  include AuthenticationHelper

  scenario 'login' do
    user = create(:plgrid_user)

    plgrid_sign_in_as(user)

    expect(page).to have_content('Successfully authenticated')
  end

  scenario 'connect with existing account' do
    user = create(:approved_user)

    sign_in_as(user)
    plgrid_sign_in_as(build(:approved_user, plgrid_login: 'plguser', email: user.email))
    user.reload

    expect(user.plgrid_login).to eq('plguser')
  end
end

