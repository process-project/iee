# frozen_string_literal: true

module StagingIn
  class StartJob < ApplicationJob
    queue_as :computation

    def perform(computation)
      StagingIn::Start.new(computation).call
    rescue StandardError => e
      Rails.logger.error(e)
      computation.update_attributes(status: 'error',
                                    error_message: e.message)
    ensure
      ComputationUpdater.new(computation).call
    end
  end
end