require 'rails_helper'

RSpec.feature 'Patient altering' do
  let(:patient) { create(:patient) }

  before(:each) do
    user = create(:user, :approved)
    login_as(user)
  end

  context 'in the context of registering a new patient' do
    scenario 'lets the user register a case with case number' do
      visit new_patient_path

      expect(page).to have_content I18n.t('simple_form.labels.patient.case_number')

      fill_in 'patient[case_number]', with: '888'

      expect { click_button I18n.t('register') }.
        to change { Patient.count }.by(1)

      expect(current_path).to eq patient_path(Patient.first)
    end

    scenario 'allows to cancel the case registration' do
      visit new_patient_path

      expect(page).to have_content I18n.t('cancel')

      click_link I18n.t('cancel')

      expect(current_path).to eq patients_path
    end

    scenario 'remembers provided field values on validation error' do
      visit new_patient_path

      fill_in 'patient[case_number]', with: patient.case_number

      expect { click_button I18n.t('register') }.
        not_to change { Patient.count }

      expect(page).to have_selector "input[value='#{patient.case_number}']"
      expect(page).to have_content 'Case number has already been taken'
    end
  end

  context 'in the context of removing a patient case' do
    scenario 'makes it possible to remove a chosen case' do
      visit patient_path(patient)

      expect(page).to have_content I18n.t('patients.show.remove')

      expect{ click_link I18n.t('patients.show.remove') }.
        to change { Patient.count }.by(-1)
    end
  end
end
