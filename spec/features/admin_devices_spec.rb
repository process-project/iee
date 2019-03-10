# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Admin users page' do
  include AuthenticationHelper

  let(:admin) do
    create(:admin)
  end

  let(:user) do
    create(:approved_user,
           password: 'asdfasdf', password_confirmation: 'asdfasdf')
  end

  before do
    login_as(admin)
  end

  scenario 'shows No Devices found' do
    visit admin_user_devices_path(user)

    expect(page).to have_content('No devices found')
  end

  scenario 'shows Devices info' do
    d = create(:device, user: user)
    create(:ip, device: d)
    visit admin_user_devices_path(user)

    expect(page).to have_content('Date and time')
    expect(page).to have_content('Device name')
    expect(page).to have_content('Last 5 IPs')
  end
end
