# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'PLGrid authentication' do
  include OauthHelper
  include AuthenticationHelper

  scenario 'login' do
    user = create(:plgrid_user)

    plgrid_sign_in_as(user)

    expect(page.body).to have_content('Successfully authenticated')
  end

  scenario 'login when email is not unique' do
    user = create(:user)
    plgrid_user = build(:plgrid_user, email: user.email)

    plgrid_sign_in_as(plgrid_user)

    expect(page.body).to have_content(I18n.t('devise.omniauth_callbacks.email_not_unique'))
  end

  scenario 'connect with existing account' do
    user = create(:approved_user)

    sign_in_as(user)
    plgrid_sign_in_as(build(:approved_user, plgrid_login: 'plguser', email: user.email))
    user.reload

    expect(user.plgrid_login).to eq('plguser')
  end

  scenario 'normal user account can connect to PLGrid no PLGRid section' do
    user = create(:approved_user)

    sign_in_as(user)

    expect(page).to have_content('Connect to PLGrid')
    expect(page).to have_selector('a', text: 'PLGrid', match: :prefer_exact)
  end

  scenario 'PLGrid user sees PLGrid section' do
    user = create(:plgrid_user)

    plgrid_sign_in_as(user)

    expect(page).to_not have_content('Connect to PLGrid')
    expect(page).to have_selector('a', text: 'PLGrid', match: :prefer_exact)
  end

  scenario 'Adds to default group new created user' do
    default_group = create(:group, default: true)
    create(:group, default: false)
    user = build(:plgrid_user)

    plgrid_sign_in_as(user)
    plgrid_user = User.find_by(email: user.email)

    expect(plgrid_user.groups).to contain_exactly(default_group)
  end

  scenario 'Don\'t add to default group after existing user plgrid login' do
    create(:group, default: true)
    user = create(:plgrid_user, :approved)

    plgrid_sign_in_as(user)

    expect(user.groups.count).to eq(0)
  end
end
