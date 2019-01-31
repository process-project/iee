# frozen_string_literal: true

module DataFiles
  class CreateJob < ApplicationJob
    queue_as :data_files

    def perform(paths)
      DataFiles::Create.new(paths).call
    end
  end
end
