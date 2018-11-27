# frozen_string_literal: true

module Rimrock
  class StartJob < ApplicationJob
    queue_as :computation

    def perform(computation)
      GuardedProxyExecutor.new(computation.user).call { start(computation) }
    end

    private

    def start(computation)
      Rimrock::Start.new(computation).call
    rescue StandardError => e
      Rails.logger.error(e)
      computation.update(status: 'error',
                         error_message: e.message)
    ensure
      ComputationUpdater.new(computation).call
    end
  end
end
