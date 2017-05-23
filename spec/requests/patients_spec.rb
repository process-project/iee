# frozen_string_literal: true
require 'rails_helper'

describe 'Patients controller' do
  include ProxySpecHelper
  include WebDavSpecHelper

  context 'with no user signed in' do
    describe 'GET /patients' do
      it 'is redirects to signin url' do
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

      it 'shows proxy oudated warning for computations' do
        user.update_attributes(proxy: outdated_proxy)
        patient.update_attributes(procedure_status: :virtual_model_ready)

        get patient_path(patient.id)

        expect(response.body).to include(I18n.t('patients.show.proxy.invalid'))
      end
    end

    describe 'DELETE /patient/:id' do
      it 'calls set_patients to prevent any data leak' do
        expect_any_instance_of(PatientsController).
          to receive(:set_patients).and_call_original
        delete "/patients/#{patient.id}"
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
  end

  it 'filters patients depending on access level' do
    pending 'A placeholder spec to remember to test filtering patients out'
    raise
  end
end
