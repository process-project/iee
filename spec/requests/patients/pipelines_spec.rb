# frozen_string_literal: true
require 'rails_helper'

describe 'Pipelines controller' do
  let(:patient) { create(:patient) }

  context 'with no user signed in' do
    describe 'GET /patients/:id/pipelines' do
      it 'is redirects to signin url' do
        get patient_pipelines_path(patient)
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  context 'with user signed in' do
    let(:user) { create(:user, :approved) }

    before(:each) do
      login_as(user)
    end

    describe 'GET /patients/:id/pipelines' do
      it 'redirects user to patient page' do
        get patient_pipelines_path(patient)
        expect(response).to redirect_to patient_path(patient)
      end
    end

    describe 'POST /patients/:id/pipelines' do
      it 'allow to create new pipeline to all logged in users' do
        expect do
          post patient_pipelines_path(patient),
               params: { pipeline: { name: 'my pipeline' } }
        end.to change { patient.pipelines.count }.by(1)
      end

      it 'current user becomes pipeline owner' do
        post patient_pipelines_path(patient),
             params: { pipeline: { name: 'my pipeline' } }

        expect(Pipeline.last.user).to eq(user)
      end
    end

    describe 'DELETE /patients/:id/pipelines/:iid' do
      it 'can be performed by owner' do
        pipeline = create(:pipeline, patient: patient, user: user)

        expect { delete patient_pipeline_path(patient, pipeline) }.
          to change { patient.pipelines.count }.by(-1)
      end

      it 'cannot be removed by no owner' do
        pipeline = create(:pipeline, patient: patient)

        expect { delete patient_pipeline_path(patient, pipeline) }.
          to_not change { patient.pipelines.count }
      end
    end

    describe 'PUT /patients/:id/pipelines/:iid' do
      it 'can be performed by owner' do
        pipeline = create(:pipeline, patient: patient, user: user, name: 'owned')

        put patient_pipeline_path(patient, pipeline),
            params: { pipeline: { name: 'updated' } }
        pipeline.reload

        expect(pipeline.name).to eq('updated')
      end

      it 'cannot be removed by no owner' do
        pipeline = create(:pipeline, patient: patient, name: 'not my')

        put patient_pipeline_path(patient, pipeline),
            params: { pipeline: { name: 'updated' } }
        pipeline.reload

        expect(pipeline.name).to eq('not my')
      end
    end
  end
end
