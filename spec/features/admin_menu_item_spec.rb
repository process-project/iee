# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Administration menu item' do
  include AuthenticationHelper
  scenario 'is visible for admin' do
    admin = create(:admin)

    sign_in_as(admin)

    expect(page).to have_content('Administration')
  end

  scenario 'is visible for supervisor' do
    supervisor = create(:supervisor_user)

    sign_in_as(supervisor)

    expect(page).to have_content('Administration')
  end

  scenario 'is invisible for user who is not admin nor supervisor' do
    user = create(:user)

    sign_in_as(user)

    expect(page).to_not have_content('Administration')
  end
end
