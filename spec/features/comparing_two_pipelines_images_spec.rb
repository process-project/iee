# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Comparing two pipelines images', files: true do
  before { DataFileType.create!(pattern: /^.*\.\b(png|bmp|jpg)\b$/, data_type: 'graphics') }

  scenario 'shows image diffs for comparable image files', js: true do
    user = create(:user, :approved, :file_store_user)
    login_as(user)

    patient = create(:patient, case_number: '7900')
    create_list(:pipeline, 2, patient: patient)

    visit patient_comparisons_path(patient, pipeline_ids: [1, 2])

    expect(page).to_not have_content 'portal6.png'
    expect(page).to have_content 'heart.bmp'
  end
end
