# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Patient browsing' do
  let(:patient) { create(:patient) }

  before(:each) do
    user = create(:user, :approved)
    login_as(user)
  end

  context 'in the context of the patients list' do
    scenario 'has left-hand menu provide a link to patients index' do
      visit root_path

      expect(page).to have_content I18n.t('patient.menu_item')

      click_link I18n.t('patient.menu_item')

      expect(current_path).to eq patients_path
    end

    scenario 'allows to add a new patient' do
      visit patients_path

      expect(page).to have_content I18n.t('patients.index.add')

      click_link I18n.t('patients.index.add')

      expect(current_path).to eq new_patient_path
    end

    scenario 'shows notification when no patients are available' do
      visit patients_path

      expect(page).to have_content I18n.t('patients.index.nothing')
    end

    scenario 'gives the file number for each patient case' do
      create_list(:data_file, 2, patient: patient)

      visit patients_path

      expect(page).to have_content "#{I18n.t 'patients.index.files'}: 2"
    end

    scenario 'lets navigate to a given patient case' do
      patient

      visit patients_path

      expect(page).to have_content(patient.case_number)

      click_link patient.case_number

      expect(current_path).to eq patient_path(patient)
    end
  end

  context 'in the context of inspecting a given case' do
    scenario 'shows proper notification for no-files case' do
      visit patient_path(patient)

      expect(page).to have_content I18n.t('patients.show.nothing')
    end

    scenario 'lets the user to go back to the patients list' do
      visit patient_path(patient)

      expect(page).to have_content I18n.t('patients.show.back')

      click_link I18n.t('patients.show.back')

      expect(current_path).to eq patients_path
    end

    scenario 'shows a table for present case data files with handles' do
      data_files = create_list(:data_file, 2, patient: patient)
      data_files[0].update_column(:handle, 'test_handle')

      visit patient_path(patient)

      expect(page).to have_content(data_files[0].name)
      expect(page).to have_content(data_files[0].data_type)
      expect(page).to have_content(data_files[1].name)
      expect(page).to have_content(data_files[1].data_type)
      expect(page).to have_content(I18n.t('patients.show.download_unavailable'))
      expect(page).to have_selector "a[href='test_handle']"
    end

    scenario 'lets the user to get a case data file from file storage' do
      pending 'waiting for storage client implementation'
      raise
    end
  end
end
