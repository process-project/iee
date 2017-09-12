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
        expect_any_instance_of(Patients::Details).to receive(:call).and_return(nil)
        get "/patients/#{patient.id}"
        expect(response.body).to include(I18n.t('patients.show.no_details'))
      end

      it 'is called and returns valid results' do
        expect_any_instance_of(Patients::Details).to receive(:call).and_return(gender: 'Male',
                                                                               birth_year: 1970,
                                                                               age: 47,
                                                                               height: 170,
                                                                               weight: 45)
        get "/patients/#{patient.id}"
        expect(response.body).to include("#{I18n.t('patients.show.gender')}: Male")
        expect(response.body).to include("#{I18n.t('patients.show.birth_year')}: 1970")
        expect(response.body).to include("#{I18n.t('patients.show.age')}: 47")
        expect(response.body).to include("#{I18n.t('patients.show.height')}: 170")
        expect(response.body).to include("#{I18n.t('patients.show.weight')}: 45")
      end
    end
  end

  it 'filters patients depending on access level' do
    pending 'A placeholder spec to remember to test filtering patients out'
    raise
  end
end
