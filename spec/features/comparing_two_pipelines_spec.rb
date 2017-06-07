# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Comparing two pipelines' do
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
      to match_array ["0", "WRONG!", "0.965", "96.5"]
  end
end
