# frozen_string_literal: true

require Rails.root.join('app', 'helpers', 'api', 'projects_helper')
include Api::ProjectsHelper

namespace :projects do
  desc 'Seed usecases projects'

  task seed: :environment do
    available_api_projects.each do |project_name|
      Project.create! project_name: project_name
    end
  end
end
