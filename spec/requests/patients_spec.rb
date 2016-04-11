require 'rails_helper'

describe 'Patients controller' do
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
        get '/patients', id: patient.id
        expect(response).to be_success
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
  end

  it 'filters patients depending on access level' do
    pending 'A placeholder spec to remember to test filtering patients out'
    fail
  end
end
