# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Delayed jobs monitoring' do
  scenario 'admin sees jobs monitoring UI' do
    admin_group = create(:group, name: 'admin')
    admin = create(:approved_user, groups: [admin_group])

    login_as(admin)
    visit(admin_job_path)

    expect(page.status_code).to eq(200)
    expect(page).to have_content(I18n.t('jobs.title'))
  end

  scenario 'normal user cannot see jobs monitoring UI' do
    user = create(:approved_user)

    login_as(user)
    expect { visit(admin_job_path) }.
      to raise_error(ActionController::RoutingError)
  end
end
