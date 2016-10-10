# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'User registration approval' do
  include AuthenticationHelper

  scenario 'not approved users cannot login' do
    user = create(:user)

    sign_in_as(user)

    expect(page.body).to have_content(I18n.t('devise.failure.user.not_approved'))
  end

  scenario 'approved users can login' do
    user = create(:approved_user)

    sign_in_as(user)

    expect(page.body).to have_content(I18n.t('devise.sessions.signed_in'))
  end
end
