# frozen_string_literal: true

module Webdav
  class StartJob < ApplicationJob
    queue_as :computation

    def perform(computation)
      ::Segmentation::Start.new(computation).call
    rescue StandardError => e
      Rails.logger.error(e)
      computation.update(status: 'error',
                         error_message: e.message)
    ensure
      ComputationUpdater.new(computation).call
    end
  end
end
