# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Patient altering' do
  include WebDavSpecHelper

  let(:patient) { create(:patient) }

  context 'for every regular user' do
    before(:each) do
      user = create(:user, :approved)
      login_as(user)
    end

    context 'when registering a new patient' do
      before { stub_webdav }

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
        expect(page).to have_content 'has already been taken'
      end
    end

    context 'when removing a patient case' do
      scenario 'makes it possible to remove a chosen case' do
        visit patient_path(patient)

        expect(page).to have_content I18n.t('patients.show.remove')

        expect { click_link I18n.t('patients.show.remove') }.
          to change { Patient.count }.by(-1)
      end
    end
  end

  context 'for every plgrid/prometheus user', files: true do
    include OauthHelper
    include AuthenticationHelper

    let(:test_proxy) do
      File.open(Rails.application.secrets[:test_proxy_path]).read
    end

    before(:each) do
      @user = create(:plgrid_user, proxy: test_proxy)

      plgrid_sign_in_as(@user)
    end

    context 'when registering a new patient' do
      scenario 'automatically synchronizes data_files and updates status' do
        allow_any_instance_of(User).to receive(:proxy).and_return(test_proxy)
        allow(Rails.application).
          to receive(:config_for).
          with('eurvalve').
          and_return(
            'data_synchronizer' => 'PlgridDataFileSynchronizer',
            'storage_url' => Rails.application.config_for('eurvalve')['storage_url'],
            'handle_url' => Rails.application.config_for('eurvalve')['handle_url']
          )

        visit new_patient_path

        fill_in 'patient[case_number]', with: '1234'

        expect { click_button I18n.t('register') }.to change { Patient.count }.by(1)

        expect(current_path).to eq patient_path(Patient.first)
        expect(page).to have_content '1234'
        expect(page).to have_content 'fluidFlow.cas'
        expect(page).to have_content 'structural_vent.dat'
      end
    end
  end

  context 'for every user with WebDAV file store access', files: true do
    before(:each) do
      @user = create(:user, :approved, :file_store_user)

      login_as(@user)
    end

    context 'when registering a new patient' do
      scenario 'automatically synchronizes data_files and updates status' do
        visit new_patient_path

        fill_in 'patient[case_number]', with: '1234'

        expect { click_button I18n.t('register') }.to change { Patient.count }.by(1)

        expect(current_path).to eq patient_path(Patient.first)
        expect(page).to have_content '1234'
      end
    end
  end
end
