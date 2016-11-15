# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Service secret token' do
  let(:user) { create(:approved_user) }

  before do
    login_as(user)
  end

  scenario 'is not visible for non service owner' do
    service = create(:service)

    visit service_path(service)

    expect(page).to_not have_content(service.token)
  end

  scenario 'is not visible for non service owner (no aliases)' do
    service = create(:service, uri_aliases: [])

    visit service_path(service)

    expect(page).to_not have_content(service.token)
  end

  scenario 'is visible for service owner' do
    service = create(:service, users: [user])

    visit service_path(service)

    expect(page).to have_content(service.token)
  end

  scenario 'is visible for service owner (no aliases)' do
    service = create(:service, uri_aliases: [], users: [user])

    visit service_path(service)

    expect(page).to have_content(service.token)
  end
end
