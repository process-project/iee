# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Comparing two pipelines', files: true do
  let(:project) { create(:project, :with_pipeline) }
  let!(:pipelines) { create_list(:pipeline, 2, project: project) }

  before(:each) do
    user = create(:user, :approved, :file_store_user)
    login_as(user)
  end

  scenario 'shows data file diffs', js: true do
    visit project_comparisons_path(project, pipeline_ids: pipelines.map(&:iid))

    expect(page).to have_content 'Result: Estimated parameters'
    expect(page).to have_css 'table.diff td.replace'
    expect(all('table.diff td.replace').map(&:text)).
      to match_array %w[0 WRONG! 0.965 96.5]
  end

  scenario 'hides non-paired and noncomparable files', js: true do
    visit project_comparisons_path(project, pipeline_ids: pipelines.map(&:iid))

    expect(page).to have_content 'Result: Blood flow model. Not compared.'
    expect(page).to have_css '.diff_output', count: 1
  end

  scenario 'refuses to work for >2 pipelines' do
    visit project_comparisons_path(project, pipeline_ids: Pipeline.all.map(&:iid))

    expect(current_path).to eq project_path(project)
  end

  scenario 'shows link to sources comparison when enough data is available' do
    visit project_comparisons_path(project, pipeline_ids: pipelines.map(&:iid))

    expect(page).not_to have_content 'Sources comparison'

    pipelines[0].computations << create(:rimrock_computation)
    pipelines[1].computations << create(:rimrock_computation,
                                        tag_or_branch: 'fixes',
                                        revision: '5678')

    visit project_comparisons_path(project, pipeline_ids: pipelines.map(&:iid))

    expect(page).to have_content 'Sources comparison'
    step = pipelines[0].computations[0].pipeline_step
    step = I18n.t("steps.#{step}.title")
    expect(page).to have_content "#{step}, rev. master:1234 vs rev. fixes:5678"
  end
end
