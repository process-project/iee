# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Patient browsing' do
  let(:patient) { create(:patient, case_number: '1234') }
  let(:user) { create(:user, :approved) }

  before(:each) do
    login_as(user)

    allow_any_instance_of(Patient).to receive(:execute_data_sync)
  end

  before do
    file_store = instance_double(Webdav::FileStore)
    allow(file_store).to receive(:r_mkdir)
    allow(Webdav::FileStore).to receive(:new).and_return(file_store)
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

    scenario 'don\'t show compare button when only one pipeline' do
      visit patient_path(patient)

      expect(page).
        to_not have_selector "input[value='#{I18n.t('patients.pipelines.tab_compare.compare')}']"
    end

    scenario 'show compare button when more than one pipeline' do
      create(:pipeline, patient: patient)
      create(:pipeline, patient: patient)

      visit patient_path(patient)

      expect(page).
        to have_selector "input[value='#{I18n.t('patients.pipelines.tab_compare.compare')}']"
    end

    scenario 'user can create new manual pipeline' do
      expect(Pipelines::StartRunnable).to_not receive(:new)
      expect do
        visit patient_path(patient)
        click_link 'Create new pipeline'
        fill_in 'Name', with: 'my new manual pipeline'
        select 'manual', from: 'Mode'
        click_on 'Create Pipeline'
      end.to change { Pipeline.count }.by(1)

      pipeline = Pipeline.last

      expect(pipeline.patient).to eq patient
      expect(pipeline.name).to eq 'my new manual pipeline'
      expect(pipeline).to be_manual
    end

    scenario 'user can create automatic pipeline, which as automatically started' do
      expect(Pipelines::StartRunnable).
        to receive(:new).and_return(double(call: true))

      expect do
        visit patient_path(patient)
        click_link 'Create new pipeline'
        fill_in 'Name', with: 'my new automatic pipeline'
        select 'automatic', from: 'Mode'
        click_on 'Create Pipeline'
      end.to change { Pipeline.count }.by(1)

      pipeline = Pipeline.last

      expect(pipeline.patient).to eq patient
      expect(pipeline.name).to eq 'my new automatic pipeline'
      expect(pipeline).to be_automatic
    end
  end

  context 'in the context of inspecting a given case pipeline' do
    scenario 'shows alert when no computation defined' do
      pipeline = create(:pipeline, patient: patient, name: 'p1')
      visit patient_pipeline_path(patient, pipeline)

      expect(page).to have_content I18n.t('patients.pipelines.show.no_computations')
    end

    context 'with automatic computations' do
      let(:pipeline) do
        pipeline = build(:pipeline,
                         patient: patient,
                         name: 'p1', user: user, mode: :automatic)
        Pipelines::Create.new(pipeline).call
      end

      let(:computation) { pipeline.computations.rimrock.first }

      scenario 'user can set computation tag_or_branch and start runnable computations' do
        mock_gitlab

        expect(Pipelines::StartRunnable).to receive_message_chain(:new, :call)
        expect_any_instance_of(Computation).to_not receive(:run)

        visit patient_pipeline_computation_path(patient, pipeline, computation)
        select('t1')
        click_button computation_run_text(computation)

        computation.reload

        expect(computation.tag_or_branch).to eq('t1')
      end
    end

    context 'with manual computations' do
      let(:pipeline) do
        pipeline = build(:pipeline,
                         patient: patient,
                         name: 'p1', user: user, mode: :manual)
        Pipelines::Create.new(pipeline).call
      end
      let(:computation) do
        pipeline.computations.find_by(pipeline_step: 'heart_model_calculation')
      end

      scenario 'redirects into first defined computation' do
        computation = pipeline.computations.first
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

      scenario 'start rimrock computation with selected version' do
        mock_rimrock_computation_ready_to_run

        expect(Rimrock::StartJob).to receive(:perform_later)

        visit patient_pipeline_computation_path(patient, pipeline, computation)
        select('bar')
        click_button computation_run_text(computation)

        computation.reload

        expect(computation.tag_or_branch).to eq 'bar'
      end

      scenario 'unable to start rimrock computation when version is not chosen' do
        mock_rimrock_computation_ready_to_run

        visit patient_pipeline_computation_path(patient, pipeline, computation)
        click_button computation_run_text(computation)

        expect(page).to have_content 'can\'t be blank'
      end

      def mock_rimrock_computation_ready_to_run
        mock_gitlab
        allow_any_instance_of(Computation).to receive(:runnable?).and_return(true)
        allow_any_instance_of(PipelineStep::HeartModelCalculation).
          to receive(:runnable?).and_return(true)
        allow_any_instance_of(Proxy).to receive(:valid?).and_return(true)
      end

      scenario 'computation alert is displayed when no required input data' do
        visit patient_pipeline_computation_path(patient, pipeline, computation)
        msg_key = "patients.pipelines.computations.show.#{computation.pipeline_step}.cannot_start"

        expect(page).to have_content I18n.t(msg_key)
      end

      context 'when computing for patient\'s wellbeing' do
        scenario 'displays computation stdout and stderr' do
          allow_any_instance_of(Computation).to receive(:runnable?).and_return(true)
          computation.update_attributes(started_at: Time.current,
                                        stdout_path: 'http://download/stdout.pl',
                                        stderr_path: 'http://download/stderr.pl')

          visit patient_pipeline_computation_path(patient, pipeline, computation)

          expect(page).to have_link('stdout', href: 'http://files/stdout.pl')
          expect(page).to have_link('stderr', href: 'http://files/stderr.pl')
        end

        # Need to wait for: https://github.com/rails/rails/pull/23211 and
        # https://github.com/rspec/rspec-rails/issues/1606
        # scenario 'periodically ajax-refreshes computation status', js: true do
        #   allow_any_instance_of(Computation).to receive(:runnable?).and_return(true)
        #   computation.update_attributes(status: 'new', started_at: Time.current)
        #
        #   visit patient_pipeline_computation_path(patient, pipeline, computation)
        #
        #   expect(page).to have_content('New')
        #
        #   computation.update_attributes(status: 'running')
        #   ComputationUpdater.new(computation).call
        #
        #   expect(page).to have_content('Running')
        # end
        #
        # scenario 'refreshes entire page when computation status turns finished', js: true do
        #   allow_any_instance_of(Computation).to receive(:runnable?).and_return(true)
        #   computation.update_attributes(status: 'new', started_at: Time.current)
        #
        #   visit patient_pipeline_computation_path(patient, pipeline, computation)
        #
        #   expect(page).to have_content('New')
        #
        #   computation.update_attributes(status: 'finished')
        #   ComputationUpdater.new(computation).call
        #
        #   expect(page).to have_content('Finished')
        # end
      end
    end

    def mock_gitlab
      allow_any_instance_of(Gitlab::Versions).
        to receive(:call).and_return(tags: %w[t1 t2], branches: %w[foo bar])
      allow_any_instance_of(Gitlab::GetFile).to receive(:call).and_return('script')
    end

    def computation_run_text(c)
      I18n.t("patients.pipelines.computations.run.#{c.pipeline_step}.start_#{c.mode}")
    end
  end
end
