# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Global policy' do
  let(:user) { create(:approved_user) }

  before { login_as(user) }

  describe 'for owned service' do
    let(:service) { create(:service, users: [user]) }

    scenario 'can be created' do
      visit new_service_global_policy_path(service)
      fill_in 'resource[name]', with: 'My resource'
      fill_in 'resource[pretty_path]', with: '/my_path'
      click_button 'Create Resource'

      expect(page).to have_content('My resource')
      expect(page).to have_content('/my_path')
    end

    scenario 'can be edited' do
      resource = create(:global_resource, service: service, name: 'name')

      visit edit_service_global_policy_path(service, resource)
      fill_in 'resource[name]', with: 'Abrakadabra'
      click_button 'Update Resource'

      expect(page.status_code).to be(200)
      expect(page).to have_content('Abrakadabra')
    end
  end

  describe 'for not owned service' do
    let(:service) { create(:service) }

    scenario 'cannot be listed' do
      visit service_global_policies_path(service)
      expect(current_path).to eq(projects_path)
    end

    scenario 'cannot be shown' do
      resource = create(:global_resource, service: service)

      visit service_global_policy_path(service, resource)
      expect(current_path).to eq(projects_path)
    end

    scenario 'cannot be edited' do
      resource = create(:global_resource, service: service)

      visit edit_service_global_policy_path(service, resource)
      expect(current_path).to eq(projects_path)
    end

    scenario 'cannot be created' do
      visit new_service_global_policy_path(service)
      expect(current_path).to eq(projects_path)
    end
  end
end
