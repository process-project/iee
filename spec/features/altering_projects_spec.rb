# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Project altering' do
  let(:project) { create(:project) }

  before(:each) do
    allow_any_instance_of(Projects::Details).
      to receive(:call).
      and_return(details: [])
  end

  context 'for every regular user' do
    before(:each) do
      user = create(:user, :approved)
      login_as(user)
    end

    context 'when registering a new project' do
      scenario 'blocks incorrect project name registration' do
        visit new_project_path

        fill_in 'project[project_name]', with: '[a stranger in the night]'

        expect { click_button I18n.t('register') }.
          not_to(change { Project.count })

        expect(page).
          to have_content I18n.t 'activerecord.errors.models.'\
          'project.attributes.project_name.invalid'
      end

      scenario 'lets the user register a project with project name' do
        visit new_project_path

        expect(page).to have_content I18n.t('simple_form.labels.project.project_name')

        fill_in 'project[project_name]', with: '888'

        expect { click_button I18n.t('register') }.
          to change { Project.count }.by(1)

        expect(current_path).to eq project_path(Project.first)
      end

      scenario 'lets the user register a project with uncommon characters' do
        visit new_project_path

        fill_in 'project[project_name]', with: '-_.'

        expect { click_button I18n.t('register') }.
          to change { Project.count }.by(1)

        expect(current_path).to eq project_path(Project.first)
      end

      scenario 'allows to cancel the project registration' do
        visit new_project_path

        expect(page).to have_content I18n.t('cancel')

        click_link I18n.t('cancel')

        expect(current_path).to eq projects_path
      end

      scenario 'remembers provided field values on validation error' do
        visit new_project_path

        fill_in 'project[project_name]', with: project.project_name

        expect { click_button I18n.t('register') }.
          not_to(change { Project.count })

        expect(page).to have_selector "input[value='#{project.project_name}']"
        expect(page).to have_content 'has already been taken'
      end
    end

    context 'when removing a project' do
      scenario 'makes it possible to remove a chosen project' do
        visit project_path(project)

        expect(page).to have_content I18n.t('projects.show.remove')

        expect { click_link I18n.t('projects.show.remove') }.
          to change { Project.count }.by(-1)
      end
    end
  end
end
