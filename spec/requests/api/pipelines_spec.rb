# frozen_string_literal: true

require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe 'Pipelines API' do
  include JsonHelpers
  include WebDavSpecHelper

  let(:user) { create(:approved_user, email: 'user@host.com') }
  let(:auth) { { 'Authorization' => "Bearer #{user.token}" } }

  context 'GET api/patients/:case_number/pipelines' do
    it 'is forbidden with invalid credentials' do
      patient = create(:patient)

      get api_patient_pipelines_path(patient)

      expect(response.status).to eq(401)
    end

    it 'lists patient\'s pipelines' do
      pipeline = create(:pipeline, iid: 1, flow: 'unused_steps')

      get api_patient_pipelines_path(pipeline.patient), headers: auth

      expect(response.status).to eq(200)
      expect(response_json).to include_json(
        data: [
          {
            type: 'pipeline',
            id: '1',
            attributes: {
              iid: 1,
              name: pipeline.name,
              flow: 'unused_steps'
            }
          }
        ]
      )
    end
  end

  context 'GET api/patients/:case_number/pipelines/:iid' do
    it 'is forbidden with invalid credentials' do
      pipeline = create(:pipeline)

      get api_patient_pipeline_path(pipeline.patient, pipeline)

      expect(response.status).to eq(401)
    end

    it 'shows important pipeline details' do
      pipeline = create(:pipeline, :with_computations, iid: 1, flow: 'unused_steps')

      get api_patient_pipeline_path(pipeline.patient, pipeline), headers: auth

      expect(response.status).to eq(200)
      expect(response_json).to include_json(
        data: {
          type: 'pipeline',
          id: '1',
          attributes: {
            iid: 1,
            name: pipeline.name,
            flow: 'unused_steps',
            inputs_dir: "test/patients/#{pipeline.patient.case_number}/pipelines/1/inputs/",
            outputs_dir: "test/patients/#{pipeline.patient.case_number}/pipelines/1/outputs/"
          }
        },
        included: [
          {
            'type': 'computation',
            'attributes': {
              'status': 'created',
              'error_message': nil,
              'exit_code': nil,
              'pipeline_step': 'blood_flow_simulation',
              'revision': nil,
              'tag_or_branch': nil,
              'required_files': %w[fluid_virtual_model ventricle_virtual_model]
            }
          },
          {
            'type': 'computation',
            'attributes': {
              'status': 'created',
              'pipeline_step': 'heart_model_calculation',
              'required_files': ['estimated_parameters']
            }
          }
        ]
      )
    end

    it 'returns 404 when pipeline is not found' do
      get api_patient_pipeline_path(build(:patient), 'not_existing'), headers: auth

      expect(response.status).to eq(404)
    end
  end

  context 'POST api/patients/:case_number/pipelines' do
    let(:body) { { data: { type: 'pipeline', attributes: { flow: 'unused_steps', name: 'p' } } } }
    let(:bad_flow_body) { { data: { type: 'pipeline', attributes: { flow: '???', name: 'p' } } } }

    it 'is forbidden with invalid credentials' do
      post api_patient_pipelines_path build(:patient), params: body

      expect(response.status).to eq(401)
    end

    it 'creates adequate pipeline structure with computations' do
      stub_webdav

      expect do
        post api_patient_pipelines_path(create(:patient), params: body), headers: auth
      end.to change { Pipeline.count }.from(0).to(1)
      pipeline = Pipeline.first

      expect(response.status).to eq(201)
      expect(pipeline).to_not be_nil
      expect(pipeline.name).to eq 'p'
      expect(pipeline.flow).to eq 'unused_steps'
      expect(pipeline.computations.count).to eq 2
    end

    it 'sets automatic and master as defaults' do
      stub_webdav

      post api_patient_pipelines_path(create(:patient), params: body), headers: auth
      pipeline = Pipeline.first

      expect(response.status).to eq(201)
      expect(pipeline.mode).to eq 'automatic'
      expect(pipeline.computations.count).to eq 2
      expect(pipeline.computations.map(&:tag_or_branch)).to eq %w[master master]
    end

    it 'detects incorrect flow attribute' do
      post api_patient_pipelines_path(create(:patient), params: bad_flow_body), headers: auth

      expect(response.status).to eq(400)
      expect(response_json).to include_json(
        flow: [
          {
            attribute: 'flow',
            message: 'is not included in the list'
          }
        ]
      )
    end

    it 'handles segmentation workflow type correctly' do
      pending 'Not implemented'
      raise 'Not implemented'
    end
  end

  context 'DELETE api/patients/:case_number/pipelines/:iid' do
    it 'is forbidden with invalid credentials' do
      pipeline = create(:pipeline)

      delete api_patient_pipeline_path(pipeline.patient, pipeline)

      expect(response.status).to eq(401)
    end

    it 'is forbidden for another user\'s pipeline' do
      pipeline = create(:pipeline)

      expect do
        delete api_patient_pipeline_path(pipeline.patient, pipeline), headers: auth
      end.not_to(change { Pipeline.count })

      expect(response.status).to eq(403)
    end

    it 'destroys pipeline' do
      pipeline = create(:pipeline, user: user)

      expect do
        delete api_patient_pipeline_path(pipeline.patient, pipeline), headers: auth
      end.to change { Pipeline.count }.from(1).to(0)

      expect(response.status).to eq(204)
    end

    it 'is not able to destroy pipeline without deleting its folder' do
      pipeline = create(:pipeline, user: user)
      allow_any_instance_of(PatientWebdav).to receive(:delete).
        and_raise(Net::HTTPServerException.new("error", 500))

      expect do
        delete api_patient_pipeline_path(pipeline.patient, pipeline), headers: auth
      end.not_to change { Pipeline.count }

      expect(response.status).to eq(500)
      expect(response.body).to eq("\"Unable to remove pipeline #{pipeline.name}.\"")
    end
  end
end
