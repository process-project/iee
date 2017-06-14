# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Patient browsing' do
  let(:patient) { create(:patient, case_number: '1234') }

  before(:each) do
    user = create(:user, :approved)
    login_as(user)

    allow_any_instance_of(Patient).to receive(:execute_data_sync)
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
    scenario 'lets the user to go back to the patients list' do
      visit patient_path(patient)

      expect(page).to have_content I18n.t('patients.show.back')

      click_link I18n.t('patients.show.back')

      expect(current_path).to eq patients_path
    end

    scenario 'shows pipelines list' do
      pipeline = create(:pipeline, patient: patient, name: 'p1')

      visit patient_path(patient)

      expect(page).to have_link('p1',
                                href: patient_pipeline_path(patient, pipeline))
    end
  end

  context 'in the context of inspecting a given case pipeline' do
    before do
      file_store = instance_double(Webdav::FileStore)
      allow(file_store).to receive(:r_mkdir)
      allow(Webdav::FileStore).to receive(:new).and_return(file_store)
    end

    scenario 'shows alert when no computation defined' do
      pipeline = create(:pipeline, patient: patient, name: 'p1')
      visit patient_pipeline_path(patient, pipeline)

      expect(page).to have_content I18n.t('patients.pipelines.show.no_computations')
    end

    context 'with computations' do
      let(:pipeline) do
        pipeline = build(:pipeline, patient: patient, name: 'p1')
        Pipelines::Create.new(pipeline).call
      end
      let(:computation) { pipeline.computations.first }

      scenario 'redirects into first defined computation' do
        visit patient_pipeline_path(patient, pipeline)

        expect(current_path).
          to eq patient_pipeline_computation_path(patient, pipeline, computation)
      end

      scenario 'all possible computations are displayed' do
        visit patient_pipeline_computation_path(patient, pipeline, computation)

        Pipeline::STEPS.each do |s|
          title = I18n.t("patients.pipelines.computations.show.#{s::STEP_NAME}.title")
          expect(page).to have_content title
        end
      end

      scenario 'computation alert is displayed when no required input data' do
        visit patient_pipeline_computation_path(patient, pipeline, computation)
        msg_key = "patients.pipelines.computations.show.#{computation.pipeline_step}.cannot_start"

        expect(page).to have_content I18n.t(msg_key)
      end

      context 'when computing for patient\'s wellbeing' do
        scenario 'displays computation stdout and stderr' do
          allow_any_instance_of(Computation).to receive(:runnable?).and_return(true)
          computation.update_attributes(status: 'new',
                                        stdout_path: 'http://download/stdout.pl',
                                        stderr_path: 'http://download/stderr.pl')

          visit patient_pipeline_computation_path(patient, pipeline, computation)

          expect(page).to have_link('stdout', href: 'http://files/stdout.pl')
          expect(page).to have_link('stderr', href: 'http://files/stderr.pl')
        end

        scenario 'periodically ajax-refreshes computation status', js: true do
          allow_any_instance_of(Computation).to receive(:runnable?).and_return(true)
          computation.update_attributes(status: 'new')

          visit patient_pipeline_computation_path(patient, pipeline, computation)

          expect(page).to have_content('New')

          page.execute_script '$(document.body).addClass("not-reloaded")'
          computation.update_attributes(status: 'running')
          page.execute_script 'window.refreshComputation($(\'div[data-refresh="true"]\'), 2)'

          expect(page).to have_content('Running')
          expect(page).to have_selector('body.not-reloaded')
        end

        scenario 'refreshes entire page when computation status turns finished', js: true do
          allow_any_instance_of(Computation).to receive(:runnable?).and_return(true)
          computation.update_attributes(status: 'new')

          visit patient_pipeline_computation_path(patient, pipeline, computation)

          expect(page).to have_content('New')

          page.execute_script '$(document.body).addClass("not-reloaded")'
          computation.update_attributes(status: 'finished')
          page.execute_script 'window.refreshComputation($(\'div[data-refresh="true"]\'), 2)'

          expect(page).to have_content('Finished')
          expect(page).not_to have_selector('body.not-reloaded')
        end
      end
    end
  end
end
