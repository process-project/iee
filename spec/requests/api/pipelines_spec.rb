# frozen_string_literal: true

require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe 'Pipelines API' do
  include JsonHelpers
  include WebDavSpecHelper

  let(:user) { create(:approved_user, email: 'user@host.com') }
  let(:auth) { { 'Authorization' => "Bearer #{user.token}" } }

  context 'show selected pipeline' do
    it 'is forbidden with invalid credentials' do
      # patient = create(:patient)
      #
      # get api_patient_path(patient)
      #
      # expect(response.status).to eq(401)
      pending; fail
    end

    it 'is allowed for valid user' do
      # patient = create(:patient)
      #
      # get api_patient_path(patient), headers: auth
      #
      # expect(response.status).to eq(200)
      pending; fail
    end

    it 'shows important pipeline details' do
      # patient = create(:patient, case_number: 'patient123')
      #
      # get api_patient_path(patient), headers: auth
      #
      # expect(response_json).to include_json(
      #   data: {
      #     type: 'patient',
      #     id: 'patient123',
      #     attributes: { case_number: 'patient123' }
      #   }
      # )
      # NOTE: inputs dir, outputs dir, computations' states, computations' required files
      pending; fail
    end

    it 'returns 404 when pipeline is not found' do
      # get api_patient_path(id: 'non_existing'), headers: auth
      #
      # expect(response.status).to eq(404)
      pending; fail
    end
  end

  context 'create new pipeline' do
    # let(:body) { { data: { attributes: { case_number: 'new_patient' } } } }

    it 'is forbidden with invalid credentials' do
      # post api_patients_path, params: body
      #
      # expect(response.status).to eq(401)
      pending; fail
    end

    it 'is allowed for valid user' do
      # stub_webdav
      #
      # post api_patients_path, params: body, headers: auth
      # patient = Patient.find_by(case_number: 'new_patient')
      #
      # expect(response.status).to eq(201)
      # expect(patient).to_not be_nil
      # expect(patient.case_number).to eq('new_patient')
      pending; fail
    end

    it 'overwrites mode to automatic' do

      pending; fail
    end

    it 'requires a specific set of pipeline attributes' do

      pending; fail
    end

    it 'detects incorrect flow attribute' do

      pending; fail
    end

    it 'sets branch to master for each rimrock computation' do

      pending; fail
    end

    it 'handles segmentation workflow type correctly' do

      pending; fail
    end
  end

  context 'destroy pipeline' do
    it 'is forbidden with invalid credentials' do
      # patient = create(:patient)
      #
      # delete api_patient_path(patient)
      #
      # expect(response.status).to eq(401)
      pending; fail
    end

    it 'is allowed for valid user' do
      # patient = create(:patient)
      #
      # delete api_patient_path(patient), headers: auth
      #
      # expect(response.status).to eq(204)
      pending; fail
    end

    it 'destroys pipeline' do
      # patient = create(:patient)
      #
      # delete api_patient_path(patient), headers: auth
      #
      # expect(Patient.exists?(patient.id)).to be_falsy
      pending; fail
    end
  end
end
