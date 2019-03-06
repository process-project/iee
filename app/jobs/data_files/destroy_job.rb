# frozen_string_literal: true

module DataFiles
  class DestroyJob < ApplicationJob
    queue_as :data_files

    def perform(paths)
      DataFiles::Destroy.new(paths).call
    end
  end
end
