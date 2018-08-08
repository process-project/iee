# frozen_string_literal: true

require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe 'Patients API' do
  include JsonHelpers
  include WebDavSpecHelper

  let(:user) { create(:approved_user, email: 'user@host.com') }
  let(:auth) { { 'Authorization' => "Bearer #{user.token}" } }

  context 'list all patients' do
    it 'is forbidden with invalid credentials' do
      get api_patients_path

      expect(response.status).to eq(401)
    end

    it 'is allowed for valid user' do
      get api_patients_path, headers: auth

      expect(response.status).to eq(200)
    end

    it 'lists all patients' do
      create(:patient, case_number: 'first')
      create(:patient, case_number: 'second')

      get api_patients_path, headers: auth

      expect(response_json).to include_json(
        data: [
          {
            type: 'patient',
            id: 'first',
            attributes: { case_number: 'first' }
          },
          {
            type: 'patient',
            id: 'second',
            attributes: { case_number: 'second' }
          }
        ]
      )
    end
  end

  context 'show selected patient' do
    it 'is forbidden with invalid credentials' do
      patient = create(:patient)

      get api_patient_path(patient)

      expect(response.status).to eq(401)
    end

    it 'is allowed for valid user' do
      patient = create(:patient)

      get api_patient_path(patient), headers: auth

      expect(response.status).to eq(200)
    end

    it 'shows patient details' do
      patient = create(:patient, case_number: 'patient123')

      get api_patient_path(patient), headers: auth

      expect(response_json).to include_json(
        data: {
          type: 'patient',
          id: 'patient123',
          attributes: { case_number: 'patient123' }
        }
      )
    end

    it 'allows to acquire pipelines iid for pipeline API use' do
      pending; fail
    end

    it 'returns 404 when patient not found' do
      get api_patient_path(id: 'non_existing'), headers: auth

      expect(response.status).to eq(404)
    end
  end

  context 'create new patient' do
    let(:body) { { data: { attributes: { case_number: 'new_patient' } } } }

    it 'is forbidden with invalid credentials' do
      post api_patients_path, params: body

      expect(response.status).to eq(401)
    end

    it 'is allowed for valid user' do
      stub_webdav

      post api_patients_path, params: body, headers: auth
      patient = Patient.find_by(case_number: 'new_patient')

      expect(response.status).to eq(201)
      expect(patient).to_not be_nil
      expect(patient.case_number).to eq('new_patient')
    end
  end

  context 'destroy patient' do
    it 'is forbidden with invalid credentials' do
      patient = create(:patient)

      delete api_patient_path(patient)

      expect(response.status).to eq(401)
    end

    it 'is allowed for valid user' do
      patient = create(:patient)

      delete api_patient_path(patient), headers: auth

      expect(response.status).to eq(204)
    end

    it 'destroys patient' do
      patient = create(:patient)

      delete api_patient_path(patient), headers: auth

      expect(Patient.exists?(patient.id)).to be_falsy
    end
  end
end
