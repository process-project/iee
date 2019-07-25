# frozen_string_literal: true

module REST
  class StartJob < ApplicationJob
    queue_as :computation

    def perform(computation)
      REST::Start.new(computation).call
    rescue StandardError => e
      Rails.logger.error(e)
      computation.update_attributes(status: 'error',
                                    error_message: e.message)
    ensure
      ComputationUpdater.new(computation).call
    end
  end
end
