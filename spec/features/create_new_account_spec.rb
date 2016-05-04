require 'rails_helper'

RSpec.feature 'User registration' do
  scenario 'email is sent to supervisors after new user registered' do
    supervisor_group = create(:group, name: 'supervisor')
    create(:user, groups: [supervisor_group])

    visit new_user_registration_path
    fill_in 'user_first_name', with: 'John'
    fill_in 'user_last_name', with: 'Doe'
    fill_in 'user_email', with: 'john@doe'
    fill_in 'user_password', with: 'verysecretpass'
    fill_in 'user_password_confirmation', with: 'verysecretpass'

    expect{
      click_on 'Register'
      # puts ">>>>> #{page.body}"
    }.
      to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
