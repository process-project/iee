# frozen_string_literal: true

require 'rails_helper'

describe 'Patients controller' do
  include ProxySpecHelper
  include WebDavSpecHelper

  context 'with no user signed in' do
    describe 'GET /patients' do
      it 'redirects to sign-in url' do
        get '/patients'
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  context 'with user signed in' do
    let(:user) { create(:user, :approved) }
    let(:patient) { create(:patient) }

    before { login_as(user) }

    describe 'GET /patients' do
      it 'calls set_patients to prevent any data leak' do
        expect_any_instance_of(PatientsController).
          to receive(:set_patients).and_call_original
        get '/patients'
        expect(response).to be_success
      end
    end

    describe 'SHOW /patient/:id' do
      it 'calls find_and_authorize to prevent any data leak' do
        expect_any_instance_of(PatientsController).
          to receive(:find_and_authorize).and_call_original
        get "/patients/#{patient.case_number}"
        expect(response).to be_success
      end
    end

    describe 'DELETE /patient/:id' do
      it 'calls find_and_authorize to prevent any data leak' do
        expect_any_instance_of(PatientsController).
          to receive(:find_and_authorize).and_call_original
        delete "/patients/#{patient.case_number}"
        expect(response).to redirect_to patients_path
      end
    end

    describe 'POST /patients' do
      before { stub_webdav }

      it 'calls execute_data_sync on newly created patient' do
        expect_any_instance_of(Patient).
          to receive(:execute_data_sync)
        expect do
          post '/patients/', params: { patient: { case_number: '5555' } }
        end.to change { Patient.count }.by(1)
        expect(response).to redirect_to Patient.first
      end
    end

    describe 'external data sets service with patient details' do
      it 'is called and returns empty result set' do
        expect_any_instance_of(Patients::Details).to receive(:call).and_return(
          status: :error,
          message: 'reason'
        )

        get patient_path(patient), xhr: true

        expect(response.body).to include(I18n.t('patients.details.no_details', details: 'reason'))
      end

      it 'is called and returns valid results' do
        expect_any_instance_of(Patients::Details).to receive(:call).and_return(
          status: :ok,
          payload: [
            [
              { name: 'gender', value: 'Male', type: 'real', style: 'default' },
              { name: 'birth_year', value: 1970, type: 'real', style: 'default' },
              { name: 'current_age', value: 50, type: 'computed', style: 'success' }
            ],
            [
              { name: 'age', value: 47, type: 'real', style: 'default' },
              { name: 'date', value: Time.current, type: 'real', style: 'default' },
              { name: 'state', value: 'Pre-op', type: 'real', style: 'default' },
              { name: 'height', value: 170, type: 'real', style: 'default' },
              { name: 'weight', value: 45, type: 'real', style: 'real' }
            ],
            [
              { name: 'state', value: 'Pre-op', type: 'inferred', style: 'default' },
              { name: 'elvmin', value: 0.45, type: 'inferred', style: 'warning' },
              { name: 'elvmax', value: 0.56, type: 'inferred', style: 'warning' }
            ]
          ]
        )

        get patient_path(patient), xhr: true

        expect(response.body).to include(I18n.t('patients.details.gender'))
        expect(response.body).to include('Male')
        expect(response.body).to include(I18n.t('patients.details.birth_year'))
        expect(response.body).to include('1970')
        expect(response.body).to include(I18n.t('patients.details.age'))
        expect(response.body).to include('47')
        expect(response.body).to include(I18n.t('patients.details.current_age'))
        expect(response.body).to include('50')
        expect(response.body).to include(I18n.t('patients.details.height'))
        expect(response.body).to include('170')
        expect(response.body).to include(I18n.t('patients.details.weight'))
        expect(response.body).to include('45')
        expect(response.body).to include(I18n.t('patients.details.elvmin'))
        expect(response.body).to include('0.45')
        expect(response.body).to include(I18n.t('patients.details.elvmax'))
        expect(response.body).to include('0.56')
      end
    end
  end

  it 'filters patients depending on access level' do
    pending 'A placeholder spec to remember to test filtering patients out'
    raise
  end
end
