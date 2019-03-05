# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Profile page' do
  include ProxySpecHelper

  let(:user) do
    create(:approved_user,
           password: 'asdfasdf', password_confirmation: 'asdfasdf')
  end

  before do
    login_as(user)
  end

  scenario 'is used to update user data' do
    visit profile_path
    fill_in 'user[first_name]', with: 'John'
    fill_in 'user[last_name]', with: 'Doe'
    fill_in 'user[email]', with: 'john@doe.com'
    click_button 'Update profile'
    user.reload

    expect(user.first_name).to eq('John')
    expect(user.last_name).to eq('Doe')
    expect(user.email).to eq('john@doe.com')
  end

  scenario 'is used to delete account' do
    visit profile_account_path

    expect { click_link 'Remove account' }.
      to change { User.count }.by(-1)
  end

  scenario 'is used to change user password' do
    visit profile_password_path
    fill_in 'user[current_password]', with: 'asdfasdf'
    fill_in 'user[password]', with: 'newpass123'
    fill_in 'user[password_confirmation]', with: 'newpass123'
    click_button 'Update password'
    user.reload

    expect(user.valid_password?('newpass123')).to be_truthy
  end

  scenario 'is used to disconect with plgrid account' do
    user.update_attributes(plgrid_login: 'plgjdoe',
                           proxy: outdated_proxy)

    visit profile_plgrid_path
    click_link 'Disconnect from PLGrid'
    user.reload

    expect(user.plgrid_login).to be_nil
    expect(user.proxy).to be_nil
  end

  scenario 'shows PLGrid proxy info' do
    user.update_attributes(plgrid_login: 'plgjdoe',
                           proxy: outdated_proxy)

    visit profile_plgrid_path

    expect(page).to have_content('Generate new proxy')
  end

  # 

  scenario 'plgrid section is visible only for connected accounts', js: true do
    skip "workaround to work with old chrome version" do
      visit profile_plgrid_path

      expect(page).to have_content('You are not authorized to perform this action.')
    end
  end
end
