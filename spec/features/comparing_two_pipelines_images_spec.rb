# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Comparing two pipelines images', files: true do
  scenario 'shows image diffs for comparable image files', js: true do
    user = create(:user, :approved, :file_store_user)
    login_as(user)

    project = create(:project, project_name: '7900')
    create_list(:pipeline, 2, project: project)

    visit project_comparisons_path(project, pipeline_ids: [1, 2])

    expect(page).to_not have_content 'portal6.png'
    expect(page).to have_content 'heart.bmp'
  end
end
