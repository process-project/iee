# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Project browsing' do
  let(:project) { create(:project, project_name: '1234') }
  let(:user) { create(:user, :approved) }

  before(:each) do
    login_as(user)

    allow_any_instance_of(Project).to receive(:execute_data_sync)
    allow_any_instance_of(Projects::Details).
      to receive(:call).
      and_return(details: [])
  end

  before do
    file_store = instance_double(Webdav::FileStore)
    allow(file_store).to receive(:r_mkdir)
    allow(Webdav::FileStore).to receive(:new).and_return(file_store)
  end

  context 'in the context of the projects list' do
    let(:stats) do
      {
        status: :ok,
        count: 4,
        test: 1,
        berlin: 2,
        sheffield: 1,
        eindhoven: 1,
        no_site: 0,
        aortic: 2,
        mitral: 2,
        no_diagnosis: 0,
        females: 2,
        males: 1,
        no_gender: 1,
        preop: 3,
        postop: 0,
        no_state: 1
      }
    end

    scenario 'has left-hand menu provide a link to projects index' do
      visit root_path

      expect(page).to have_content I18n.t('layouts.left_menu.research.projects')

      click_link I18n.t('layouts.left_menu.research.projects')

      expect(current_path).to eq projects_path
    end

    scenario 'allows to add a new project' do
      visit projects_path

      expect(page).to have_content I18n.t('projects.index.add')

      click_link I18n.t('projects.index.add')

      expect(current_path).to eq new_project_path
    end

    scenario 'shows notification when no projects are available' do
      visit projects_path

      expect(page).to have_content I18n.t('projects.index.nothing')
    end

    scenario 'gives the file number for each project' do
      create_list(:data_file, 2, project: project)

      visit projects_path

      expect(page).to have_content "#{I18n.t 'projects.index.files'}: 2"
    end

    scenario 'gives the pipeline number for each project' do
      create(:pipeline, project: project)

      visit projects_path

      expect(page).to have_content "#{I18n.t 'projects.index.pipelines'}: 1"
    end

    scenario 'lets navigate to a given project' do
      project

      visit projects_path

      expect(page).to have_content(project.project_name)

      click_link project.project_name

      expect(current_path).to eq project_path(project)
    end

    scenario 'does not fret when there are no pipelines' do
      project

      visit projects_path

      expect(page).to have_content I18n.t('projects.index.no_pipelines')
    end

    scenario 'lists pipeline steps in correct flow order' do
      create(:pipeline, :with_computations, project: project)

      visit projects_path

      expect(page).to have_selector(
        ".progress a:nth-child(1) #{bar_selector('placeholder_step')}"
      )
    end

    def bar_selector(step_name)
      ".progress-bar[title='#{I18n.t("steps.#{step_name}.title")}']"
    end
  end

  context 'in the context of inspecting a given project' do
    let(:details) do
      {
        status: :ok,
        payload: [
          {
            name: 'state',
            value: 'Pre-op',
            style: 'default',
            type: 'real'
          }
        ]
      }
    end

    scenario 'lets the user to go back to the projects list' do
      visit project_path(project)

      expect(page).to have_content I18n.t('projects.show.back')

      click_link I18n.t('projects.show.back')

      expect(current_path).to eq projects_path
    end

    scenario 'shows pipelines list' do
      pipeline = create(:pipeline, project: project, name: 'p1')

      visit project_path(project)

      expect(page).to have_link('p1',
                                href: project_pipeline_path(project, pipeline))
      expect(page).to have_content I18n.t("simple_form.options.pipeline.flow.#{pipeline.flow}")
      expect(page).to have_content pipeline.user.name
    end

    scenario 'don\'t show compare button when only one pipeline' do
      visit project_path(project)

      expect(page).
        to_not have_selector "input[value='#{I18n.t('projects.pipelines.tab_compare.compare')}']"
    end

    scenario 'show compare button when more than one pipeline' do
      create(:pipeline, project: project)
      create(:pipeline, project: project)

      visit project_path(project)

      expect(page).
        to have_selector "input[value='#{I18n.t('projects.pipelines.tab_compare.compare')}']"
    end

    scenario 'user can create new manual pipeline' do
      expect(Pipelines::StartRunnable).to_not receive(:new)
      expect do
        visit project_path(project)
        click_link 'Set up new pipeline'
        fill_in 'Name', with: 'my new manual pipeline'
        select 'manual', from: 'Mode'
        click_on 'Set up new pipeline'
      end.to change { Pipeline.count }.by(1)

      pipeline = Pipeline.last

      expect(pipeline.project).to eq project
      expect(pipeline.name).to eq 'my new manual pipeline'
      expect(pipeline).to be_manual
    end

    scenario 'user can create automatic pipeline, which is automatically started' do
      expect(Pipelines::StartRunnable).
        to receive(:new).and_return(double(call: true))

      expect do
        visit project_path(project)
        click_link 'Set up new pipeline'
        fill_in 'Name', with: 'my new automatic pipeline'
        select 'automatic', from: 'Mode'
        click_on 'Set up new pipeline'
      end.to change { Pipeline.count }.by(1)

      pipeline = Pipeline.last

      expect(pipeline.project).to eq project
      expect(pipeline.name).to eq 'my new automatic pipeline'
      expect(pipeline).to be_automatic
    end

    scenario 'error details are displayed when pipeline cannot be created' do
      visit project_path(project)
      click_link 'Set up new pipeline'
      click_on 'Set up new pipeline'

      expect(page).to have_content('can\'t be blank')
    end
  end

  context 'in the context of inspecting a given project pipeline' do
    scenario 'displays basic info about a pipeline' do
      pipeline = create(:pipeline, project: project)
      visit project_pipeline_path(project, pipeline)

      expect(page).to have_content pipeline.name
      expect(page).to have_content I18n.t("simple_form.options.pipeline.flow.#{pipeline.flow}")
      expect(page).to have_content pipeline.user.name
    end

    scenario 'lists pipeline steps in correct flow order' do
      pipeline = create(:pipeline, :with_computations, project: project)

      visit project_pipeline_path(project, pipeline)

      expect(page).to have_selector(
        '#computations li:nth-child(1) a', text: I18n.t('steps.placeholder_step.title')
      )
    end

    scenario 'shows alert when no computation defined' do
      pipeline = create(:pipeline, project: project, name: 'p1')
      visit project_pipeline_path(project, pipeline)

      expect(page).to have_content I18n.t('projects.pipelines.show.no_computations')
    end

    context 'with automatic computations' do
      let(:pipeline) do
        pipeline = build(:pipeline,
                         project: project,
                         name: 'p1', user: user, mode: :automatic)
        Pipelines::Create.new(pipeline, {}).call
      end

      let(:computation) { pipeline.computations.rimrock.first }

      scenario 'user can set computation tag_or_branch and start runnable computations' do
        mock_gitlab

        expect(Pipelines::StartRunnable).to receive_message_chain(:new, :call)
        expect_any_instance_of(Computation).to_not receive(:run)

        visit project_pipeline_computation_path(project, pipeline, computation)
        select('t1')
        click_button computation_run_text(computation)

        computation.reload

        expect(computation.tag_or_branch).to eq('t1')
      end
    end

    context 'with manual computations' do
      let(:pipeline) do
        pipeline = build(:pipeline,
                         project: project,
                         flow: 'placeholder_pipeline',
                         name: 'p1', user: user, mode: :manual)
        Pipelines::Create.new(pipeline, {}).call
      end
      let(:computation) do
        pipeline.computations.find_by(type: 'RimrockComputation')
      end

      scenario 'redirects into first defined computation' do
        computation = pipeline.computations.first
        visit project_pipeline_path(project, pipeline)

        expect(current_path).
          to eq project_pipeline_computation_path(project, pipeline, computation)
      end

      scenario 'all possible computations are displayed' do
        visit project_pipeline_computation_path(project, pipeline, computation)

        pipeline.steps.each do |step|
          title = I18n.t("steps.#{step.name}.title")
          expect(page).to have_content title
        end
      end

      scenario 'start rimrock computation with selected version' do
        mock_rimrock_computation_ready_to_run

        expect(Rimrock::StartJob).to receive(:perform_later)

        visit project_pipeline_computation_path(project, pipeline, computation)
        select('bar')
        click_button computation_run_text(computation)

        computation.reload

        expect(computation.tag_or_branch).to eq 'bar'
      end

      scenario 'show started rimrock computation source link for started step' do
        computation = pipeline.computations.
                      find_by(pipeline_step: 'placeholder_step')
        computation.update_attributes(revision: 'my-revision',
                                      started_at: Time.zone.now)

        visit project_pipeline_computation_path(project, pipeline, computation)

        expect(page).to have_link 'my-revision'
        expect(page).
          to have_link href: 'https://gitlab.com/process-eu/mock-step/tree/my-revision'
      end

      scenario 'rimrock computation source link is not shown when no revision' do
        computation = pipeline.computations.
                      find_by(pipeline_step: 'placeholder_step')

        visit project_pipeline_computation_path(project, pipeline, computation)

        expect(page).
          to_not have_link href: 'https://gitlab.com/process-eu/mock-step/tree'
      end

      scenario 'unable to start rimrock computation when version is not chosen' do
        mock_rimrock_computation_ready_to_run

        visit project_pipeline_computation_path(project, pipeline, computation)
        click_button computation_run_text(computation)

        expect(page).to have_content 'can\'t be blank'
      end

      # scenario 'start webdav computation' do
      #   mock_webdav_computation_ready_to_run
      #   computation = pipeline.computations.
      #                 find_by(pipeline_step: 'placeholder_step')
      #   create(:data_file, data_type: :image, patient: patient)

      #   expect(Webdav::StartJob).to receive(:perform_later)

      #   visit patient_pipeline_computation_path(patient, pipeline, computation)
      #   # select('Workflow 5 (Mitral Valve TEE Segmentation)')
      #   click_button computation_run_text(computation)
      # end

      # scenario 'unable to start webdav computation when run_mode is not set' do
      #   mock_webdav_computation_ready_to_run
      #   computation = pipeline.computations.
      #                 find_by(pipeline_step: 'placeholder_step')
      #   create(:data_file, data_type: :image, patient: patient)

      #   visit patient_pipeline_computation_path(patient, pipeline, computation)
      #   click_button computation_run_text(computation)

      #   expect(page).to have_content 'can\'t be blank'
      # end

      def mock_rimrock_computation_ready_to_run
        mock_gitlab
        allow_any_instance_of(Computation).to receive(:runnable?).and_return(true)
        allow_any_instance_of(RimrockStep).
          to receive(:input_present_for?).and_return(true)
        allow_any_instance_of(Proxy).to receive(:valid?).and_return(true)
      end

      def mock_webdav_computation_ready_to_run
        allow_any_instance_of(WebdavComputation).
          to receive(:runnable?).and_return(true)
      end

      # scenario 'computation alert is displayed when no required input data' do
      #   visit patient_pipeline_computation_path(patient, pipeline, computation)
      #   msg_key = "steps.#{computation.pipeline_step}.cannot_start"

      #   expect(page).to have_content I18n.t(msg_key)
      # end

      context 'when computing for project\'s wellbeing' do
        scenario 'displays computation stdout and stderr' do
          allow_any_instance_of(Computation).to receive(:runnable?).and_return(true)
          computation.update_attributes(started_at: Time.current,
                                        stdout_path: 'http://download/stdout.pl',
                                        stderr_path: 'http://download/stderr.pl')

          visit project_pipeline_computation_path(project, pipeline, computation)

          expect(page).to have_link('stdout', href: 'http://files/stdout.pl')
          expect(page).to have_link('stderr', href: 'http://files/stderr.pl')
        end

        # Need to wait for: https://github.com/rails/rails/pull/23211 and
        # https://github.com/rspec/rspec-rails/issues/1606
        # scenario 'periodically ajax-refreshes computation status', js: true do
        #   allow_any_instance_of(Computation).to receive(:runnable?).and_return(true)
        #   computation.update_attributes(status: 'new', started_at: Time.current)
        #
        #   visit project_pipeline_computation_path(project, pipeline, computation)
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
        #   visit project_pipeline_computation_path(project, pipeline, computation)
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
      I18n.t("steps.#{c.pipeline_step}.start_#{c.mode}")
    end
  end
end
