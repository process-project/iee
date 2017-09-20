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
      it 'calls set_patients to prevent any data leak' do
        expect_any_instance_of(PatientsController).
          to receive(:set_patients).and_call_original
        get '/patients', params: { id: patient.id }
        expect(response).to be_success
      end
    end

    describe 'DELETE /patient/:id' do
      it 'calls set_patients to prevent any data leak' do
        expect_any_instance_of(PatientsController).
          to receive(:set_patients).and_call_original
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

        get "/patients/#{patient.case_number}"

        expect(response.body).to include(I18n.t('patients.show.no_details', details: 'reason'))
      end

      it 'is called and returns valid results' do
        expect_any_instance_of(Patients::Details).to receive(:call).and_return(
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

        get "/patients/#{patient.case_number}"

        expect(response.body).to include("#{I18n.t('patients.show.gender')}: Male")
        expect(response.body).to include("#{I18n.t('patients.show.birth_year')}: 1970")
        expect(response.body).to include("#{I18n.t('patients.show.age')}: 47")
        expect(response.body).to include("#{I18n.t('patients.show.current_age')}: 50")
        expect(response.body).to include("#{I18n.t('patients.show.height')}: 170")
        expect(response.body).to include("#{I18n.t('patients.show.weight')}: 45")
        expect(response.body).to include("#{I18n.t('patients.show.elvmin')}: 0.5")
      end
    end
  end

  it 'filters patients depending on access level' do
    pending 'A placeholder spec to remember to test filtering patients out'
    raise
  end
end
