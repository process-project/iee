# frozen_string_literal: true

require 'rails_helper'

describe 'Projects controller' do
  include ProxySpecHelper
  include WebDavSpecHelper

  context 'with no user signed in' do
    describe 'GET /projects' do
      it 'redirects to sign-in url' do
        get '/projects'
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  context 'with user signed in' do
    let(:user) { create(:user, :approved) }
    let(:project) { create(:project) }

    before { login_as(user) }

    describe 'GET /projects' do
      it 'calls set_projects to prevent any data leak' do
        expect_any_instance_of(ProjectsController).
          to receive(:set_projects).and_call_original
        get '/projects'
        expect(response).to be_success
      end
    end

    describe 'SHOW /project/:id' do
      it 'calls find_and_authorize to prevent any data leak' do
        expect_any_instance_of(ProjectsController).
          to receive(:find_and_authorize).and_call_original
        get "/projects/#{project.project_name}"
        expect(response).to be_success
      end
    end

    describe 'DELETE /project/:id' do
      it 'calls find_and_authorize to prevent any data leak' do
        expect_any_instance_of(ProjectsController).
          to receive(:find_and_authorize).and_call_original
        delete "/projects/#{project.project_name}"
        expect(response).to redirect_to projects_path
      end
    end

    describe 'POST /projects' do
      before { stub_webdav }

      it 'calls execute_data_sync on newly created project' do
        expect_any_instance_of(Project).
          to receive(:execute_data_sync)
        expect do
          post '/projects/', params: { project: { project_name: '5555' } }
        end.to change { Project.count }.by(1)
        expect(response).to redirect_to Project.first
      end
    end

    describe 'external data sets service with project details' do
      it 'is called and returns empty result set' do
        expect_any_instance_of(Projects::Details).to receive(:call).and_return(
          status: :error,
          message: 'reason'
        )

        get project_path(project), xhr: true

        expect(response.body).to include(I18n.t('projects.details.no_details', details: 'reason'))
      end

      it 'is called and returns valid results' do
        expect_any_instance_of(Projects::Details).to receive(:call).and_return(
          status: :ok,
          payload: [
            { name: 'gender', value: 'Male', type: 'real', style: 'default' },
            { name: 'birth_year', value: 1970, type: 'real', style: 'default' },
            { name: 'age', value: 47, type: 'real', style: 'default' },
            { name: 'current_age', value: 50, type: 'computed', style: 'success' },
            { name: 'height', value: 170, type: 'real', style: 'default' },
            { name: 'weight', value: 45, type: 'real', style: 'real' },
            { name: 'elvmin', value: 0.5, type: 'inferred', style: 'warning' }
          ]
        )

        get project_path(project), xhr: true

        expect(response.body).to include("#{I18n.t('projects.details.gender')}: Male")
        expect(response.body).to include("#{I18n.t('projects.details.birth_year')}: 1970")
        expect(response.body).to include("#{I18n.t('projects.details.age')}: 47")
        expect(response.body).to include("#{I18n.t('projects.details.current_age')}: 50")
        expect(response.body).to include("#{I18n.t('projects.details.height')}: 170")
        expect(response.body).to include("#{I18n.t('projects.details.weight')}: 45")
        expect(response.body).to include("#{I18n.t('projects.details.elvmin')}: 0.5")
      end
    end
  end

  it 'filters projects depending on access level' do
    pending 'A placeholder spec to remember to test filtering projects out'
    raise
  end
end
