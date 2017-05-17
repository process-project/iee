# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Patient browsing' do
  let(:patient) { create(:patient, case_number: '1234') }

  before(:each) do
    user = create(:user, :approved)
    login_as(user)
  end

  context 'in the context of the patients list' do
    scenario 'has left-hand menu provide a link to patients index' do
      visit root_path

      expect(page).to have_content I18n.t('layouts.left_menu.research.patients')

      click_link I18n.t('layouts.left_menu.research.patients')

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

    scenario 'shows pipelines list' do
      pipeline = create(:pipeline, patient: patient, name: 'p1')

      visit patient_path(patient)

      expect(page).to have_link('p1',
                                href: patient_pipeline_path(patient, pipeline))
    end

    scenario 'lets the user to go back to the patients list' do
      visit patient_path(patient)

      expect(page).to have_content I18n.t('patients.show.back')

      click_link I18n.t('patients.show.back')

      expect(current_path).to eq patients_path
    end

    context 'when computing for patient\'s wellbeing' do
      scenario 'displays computations related to the patient\'s state' do
        create(:computation, patient: patient)

        visit patient_path(patient)

        expect(page).not_to have_content('Computations')

        patient.imaging_uploaded!
        visit patient_path(patient)

        expect(page).to have_content('Computations')
        expect(page).to have_content(I18n.t('computation.for_procedure_status.imaging_uploaded'))
        expect(page).to have_content('New')

        create(:computation, patient: patient, pipeline_step: 'virtual_model_ready')
        patient.virtual_model_ready!
        visit patient_path(patient)

        expect(page).to have_content('Computations')
        expect(page).to have_content(I18n.t('computation.for_procedure_status.virtual_model_ready'))
        expect(page).to have_content('New')

        create(:computation, patient: patient, pipeline_step: 'after_parameter_estimation')
        patient.after_parameter_estimation!
        visit patient_path(patient)

        expect(page).to have_content('Computations')
        expect(page).to have_content(
          I18n.t('computation.for_procedure_status.after_parameter_estimation')
        )
        expect(page).to have_content('New')
      end

      scenario 'displays computation stdout and stderr' do
        create(:computation, patient: patient,
                             stdout_path: 'http://download/stdout.pl',
                             stderr_path: 'http://download/stderr.pl')

        patient.imaging_uploaded!
        visit patient_path(patient)

        expect(page).to have_link('stdout', href: 'http://files/stdout.pl')
        expect(page).to have_link('stderr', href: 'http://files/stderr.pl')
      end

      scenario 'creates new computations of appropriate type' do
        allow(Rimrock::StartJob).to receive(:perform_later) {}
        allow_any_instance_of(ProxyHelper).to receive(:proxy_valid?) { true }

        patient.virtual_model_ready!
        visit patient_path(patient)

        expect(page).to have_content('Computations')
        expect(page).
          to have_content(I18n.t('patients.show.new_computation.virtual_model_ready'))

        expect { click_button 'Execute simulation' }.
          to change { Computation.where(pipeline_step: 'virtual_model_ready').count }.by(1)

        patient.after_parameter_estimation!
        visit patient_path(patient)

        expect(page).to have_content('Computations')
        expect(page).
          to have_content(I18n.t('patients.show.new_computation.after_parameter_estimation'))

        expect { click_button 'Execute simulation' }.
          to change { Computation.where(pipeline_step: 'after_parameter_estimation').count }.by(1)
      end

      scenario 'periodically ajax-refreshes computation status', js: true do
        computation = create(:computation, patient: patient, pipeline_step: 'virtual_model_ready')
        patient.virtual_model_ready!

        visit patient_path(patient)

        expect(page).to have_content('New')

        page.execute_script '$(document.body).addClass("not-reloaded")'
        computation.update_attributes(status: 'running')
        page.execute_script 'window.refreshComputation($(\'tr[data-refresh="true"]\'), 2)'

        expect(page).to have_content('Running')
        expect(page).to have_selector('body.not-reloaded')
      end

      scenario 'refreshes entire page when computation status turns finished', js: true do
        computation = create(:computation, patient: patient, pipeline_step: 'virtual_model_ready')
        patient.virtual_model_ready!

        visit patient_path(patient)

        expect(page).to have_content('New')

        page.execute_script '$(document.body).addClass("not-reloaded")'
        computation.update_attributes(status: 'finished')
        page.execute_script 'window.refreshComputation($(\'tr[data-refresh="true"]\'), 2)'

        expect(page).to have_content('Finished')
        expect(page).not_to have_selector('body.not-reloaded')
      end
    end

    context 'with plgrid file backend' do
      scenario 'shows a table for present case data files with handles' do
        allow(Rails.application).
          to receive(:config_for).
          with('eurvalve').
          and_return(
            'data_synchronizer' => 'PlgridDataFileSynchronizer',
            'storage_url' => Rails.application.config_for('eurvalve')['storage_url'],
            'handle_url' => Rails.application.config_for('eurvalve')['handle_url']
          )

        data_files = create_list(:data_file, 2, patient: patient)
        data_files[0].update_attributes(handle: 'test_handle')

        visit patient_path(patient)

        expect(page).to have_content(data_files[0].name)
        expect(page).to have_content(data_files[0].data_type)
        expect(page).to have_content(data_files[1].name)
        expect(page).to have_content(data_files[1].data_type)
        expect(page).to have_content(I18n.t('patients.show.download_unavailable'))
        expect(page).to have_selector "a[href='test_handle']"
      end
    end
  end
end
