# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'PLGrid proxy', js: true do
  scenario 'show warning when user has active computations and proxy is outdated' do
    user = create(:user, :approved)
    create(:scripted_computation, status: 'new', user: user, deployment: 'cluster')
    login_as(user)

    visit root_path

    expect(page).to have_content('Your proxy certificate is outdated')
  end
end
