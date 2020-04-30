# frozen_string_literal: true

module Lobcder
  class StartJob < ApplicationJob
    queue_as :computation

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def perform(computation)
      if computation.step.class.name == 'DirectoryBuilderStep'
        Lobcder::DirectoryBuilderStart.new(computation).call
      elsif computation.step.class.name == 'StagingInStep'
        Lobcder::StagingInStart.new(computation).call
      elsif computation.step.class.name == 'StagingOutStep'
        Lobcder::StagingOutStart.new(computation).call
      elsif computation.step.class.name == 'ImplicitStagingStep'
        Lobcder::ImplicitStagingStart.new(computation).call
      elsif computation.step.class.name == 'CleanUpStep'
        Lobcder::CleanUpStart.new(computation).call
      end
    rescue StandardError => e
      Rails.logger.error(e)
      computation.update_attributes(status: 'error',
                                    error_message: e.message)
    ensure
      ComputationUpdater.new(computation).call
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
  end
end
