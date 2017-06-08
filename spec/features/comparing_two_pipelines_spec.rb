# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Comparing two pipelines', files: true do
  let(:patient) { create(:patient, :with_pipeline) }
  let!(:pipelines) { create_list(:pipeline, 2, patient: patient) }

  before(:each) do
    user = create(:user, :approved, :file_store_user)
    login_as(user)
  end

  scenario 'shows data file diffs', js: true do
    visit patient_comparison_path(patient, id: patient.id, pipeline_ids: pipelines.map(&:iid))

    expect(page).to have_content 'Result: Estimated parameters'
    expect(page).to have_css 'table.diff td.replace'
    expect(all('table.diff td.replace').map(&:text)).
      to match_array %w(0 WRONG! 0.965 96.5)
  end

  scenario 'hides non-paired and noncomparable files', js: true do
    visit patient_comparison_path(patient, id: patient.id, pipeline_ids: pipelines.map(&:iid))

    expect(page).to have_content 'Result: Blood flow model. Not compared.'
    expect(page).to have_css '.diff_output', count: 1
  end

  scenario 'refuses to work for >2 pipelines' do
    visit patient_comparison_path(patient, id: patient.id, pipeline_ids: Pipeline.all.map(&:iid))

    expect(current_path).to eq patient_path(patient)
  end
end
