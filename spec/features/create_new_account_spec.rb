# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User registration' do
  before do
    supervisor_group = create(:group, name: 'supervisor')
    create(:user, groups: [supervisor_group])
  end

  scenario 'email is sent to supervisors after new user registered' do
    fill_registration_form

    expect { click_on 'Register' }.
      to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  scenario 'email is not sent when user is not created' do
    visit new_user_registration_path

    expect { click_on 'Register' }.
      to_not(change { ActionMailer::Base.deliveries.count })
  end

  scenario 'new created user is added to default groups' do
    default_group = create(:group, default: true)
    create(:group)

    fill_registration_form
    click_on 'Register'
    user = User.last

    expect(user.groups).to contain_exactly(default_group)
  end

  private

  def fill_registration_form
    visit new_user_registration_path

    fill_in 'user_first_name', with: 'John'
    fill_in 'user_last_name', with: 'Doe'
    fill_in 'user_email', with: 'john@doe'
    fill_in 'user_password', with: 'verysecretpass'
    fill_in 'user_password_confirmation', with: 'verysecretpass'
  end
end
