# frozen_string_literal: true

module Lobcder
  class StartJob < ApplicationJob
    queue_as :computation

    def perform(computation)
      if computation.step.class.name == 'DirectoryBuilderStep'
        Lobcder::DirectoryBuilderStart.new(computation).call
      elsif computation.step.class.name == 'StagingInStep'
        Lobcder::StagingInStart.new(computation).call
      elsif computation.step.class.name == 'StagingOutStep'
        Lobcder::StagingOutStart.new(computation).call
      elsif computation.step.class.name == 'ImplicitStagingStep'
        Lobcder::ImplicitStagingStart.new(computation).call
      end
    rescue StandardError => e
      Rails.logger.error(e)
      computation.update_attributes(status: 'error',
                                    error_message: e.message)
    ensure
      ComputationUpdater.new(computation).call
    end
  end
end
