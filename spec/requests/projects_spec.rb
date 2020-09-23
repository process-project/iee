# frozen_string_literal: true

require 'rails_helper'

describe 'Projects controller' do
  include ProxySpecHelper

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
  end

  it 'filters projects depending on access level' do
    pending 'A placeholder spec to remember to test filtering projects out'
    raise
  end
end
