# frozen_string_literal: true

module DataFiles
  class CreateJob < ApplicationJob
    queue_as :data_files

    def perform(paths)
      created_data_files = DataFiles::Create.new(paths).call

      Pipelines::Affected.new(created_data_files).call.
        each { |p| Pipelines::StartRunnableJob.perform_later(p) }
    end
  end
end
