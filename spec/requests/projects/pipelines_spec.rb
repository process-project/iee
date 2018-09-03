# frozen_string_literal: true

require 'rails_helper'

describe 'Pipelines controller' do
  include WebDavSpecHelper

  let(:project) { create(:project) }

  context 'with no user signed in' do
    describe 'GET /projects/:id/pipelines' do
      it 'is redirects to signin url' do
        get project_pipelines_path(project)
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  context 'with user signed in' do
    let(:user) { create(:user, :approved) }

    before(:each) do
      login_as(user)
    end

    describe 'GET /projects/:id/pipelines' do
      it 'redirects user to project page' do
        get project_pipelines_path(project)
        expect(response).to redirect_to project_path(project)
      end
    end

    describe 'POST /projects/:id/pipelines' do
      before { stub_webdav }

      it 'allow to run pipelines for all logged in users' do
        expect do
          post project_pipelines_path(project),
               params: { pipeline: { name: 'my pipeline',
                                     flow: 'placeholder_pipeline',
                                     mode: 'manual' } }
        end.to change { project.pipelines.count }.by(1)
      end

      it 'current user becomes pipeline owner' do
        post project_pipelines_path(project),
             params: { pipeline: { name: 'my pipeline',
                                   flow: 'placeholder_pipeline',
                                   mode: 'manual' } }

        expect(Pipeline.last.user).to eq(user)
      end
    end

    describe 'DELETE /projects/:id/pipelines/:iid' do
      before { stub_webdav }

      it 'can be performed by owner' do
        pipeline = create(:pipeline, project: project, user: user)

        expect { delete project_pipeline_path(project, pipeline) }.
          to change { project.pipelines.count }.by(-1)
      end

      it 'cannot be removed by no owner' do
        pipeline = create(:pipeline, project: project)

        expect { delete project_pipeline_path(project, pipeline) }.
          to_not(change { project.pipelines.count })
      end
    end

    describe 'PUT /projects/:id/pipelines/:iid' do
      it 'can be performed by owner' do
        pipeline = create(:pipeline, project: project, user: user, name: 'owned')

        put project_pipeline_path(project, pipeline),
            params: { pipeline: { name: 'updated' } }
        pipeline.reload

        expect(pipeline.name).to eq('updated')
      end

      it 'cannot be removed by no owner' do
        pipeline = create(:pipeline, project: project, name: 'not my')

        put project_pipeline_path(project, pipeline),
            params: { pipeline: { name: 'updated' } }
        pipeline.reload

        expect(pipeline.name).to eq('not my')
      end
    end
  end
end
